//
//  OTestView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 07.06.2022.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

protocol OTestViewDelegate: AnyObject {
    func testViewDidFinished()
}

final class OTestView: OSlideView {
    weak var vc: UIViewController?
    weak var testViewDelegate: OTestViewDelegate?
    
    lazy var progressLabel = makeLabel()
    lazy var favoriteButton = makeFavoriteButton()
    lazy var tableView = makeTableView()
    lazy var preloader = makePreloader()
    
    private lazy var questionManager = QuestionManager()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private lazy var selectedExam = BehaviorRelay<Exam?>(value: nil)
    private lazy var selectedCourse = BehaviorRelay<Course?>(value: nil)
    
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: OExamsViewDelegate
extension OTestView: OExamsViewDelegate {
    func examsDidSelected(element: Exam) {
        selectedExam.accept(element)
    }
}

// MARK: OCourseViewDelegate
extension OTestView: OCourseViewDelegate {
    func courseViewDidSelected(course: Course) {
        selectedCourse.accept(course)
    }
}

// MARK: Private
private extension OTestView {
    func initialize() {
        backgroundColor = Appearance.mainColor
        
        Driver
            .combineLatest(
                selectedExam
                    .compactMap { $0 }
                    .asDriver(onErrorDriveWith: .never()),
                selectedCourse
                    .compactMap { $0 }
                    .asDriver(onErrorDriveWith: .never())
            )
            .flatMapLatest { [weak self] exam, course -> Driver<Test> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Test> {
                    self.questionManager
                        .obtainOnboardingTest(domain: exam.domain,
                                              apiKey: exam.api,
                                              courseId: course.id,
                                              forceUpdate: true)
                        .flatMap { test -> Single<Test> in
                            guard let test = test else {
                                return .error(ContentError(.notContent))
                            }
                            
                            return .just(test)
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    self.openError()
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
            .drive(Binder(self) { base, test in
                base.start(questions: test.questions) {
                    base.testViewDelegate?.testViewDidFinished()
                }
            })
            .disposed(by: disposeBag)
        
        activity
            .drive(Binder(self) { base, activity in
                activity ? base.preloader.startAnimating() : base.preloader.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap
            .withLatestFrom(selectedExam)
            .flatMapFirst { [weak self] exam -> Observable<Bool> in
                guard let self = self, let exam = exam else {
                    return .empty()
                }
                
                let isSaved = self.favoriteButton.isFavorite
                let questionId = self.favoriteButton.question.id
                
                func source() -> Single<Bool> {
                    let request = isSaved
                    ? self.questionManager.removeSavedQuestion(domain: exam.domain, apiKey: exam.api, questionId: questionId)
                    : self.questionManager.saveQuestion(domain: exam.domain, apiKey: exam.api, questionId: questionId)
                    
                    return request
                        .map { !isSaved }
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { error in self.openError() })
            }
            .asDriver(onErrorDriveWith: .never())
            .drive(Binder(self) { base, isFavorite in
                base.favoriteButton.isFavorite = isFavorite
            })
            .disposed(by: disposeBag)
    }
    func start(questions: [Question], completion: @escaping () -> Void) {
        setup(questions: questions, index: 0, completion: completion)
    }
    
    func setup(questions: [Question], index: Int, completion: @escaping () -> Void) {
        guard !questions.isEmpty, questions.indices.contains(index) else {
            completion()
            return
        }
        
        let question = questions[index]
        
        setup(question: question) { [weak self] in
            self?.setup(questions: questions, index: index + 1, completion: completion)
        }
        
        let attrs = TextAttributes()
            .textColor(Appearance.whiteColor)
            .font(Fonts.Inter.semiBold(size: 17.scale))
            .lineHeight(20.4.scale)
            .letterSpacing(-0.44.scale)
        let progress = String(format: "%i/%i", index + 1, questions.count)
        progressLabel.attributedText = progress.attributed(with: attrs)
        
        favoriteButton.question = question
    }
    
    func setup(question: Question, completion: @escaping () -> Void) {
        var elements = [OQuestionTableElement]()
        
        elements.append(contentsOf: [
            .question(question.question),
            .offset(20.scale)
        ])
        
        let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"]
        
        question.answers.enumerated().forEach { index, answer in
            let element = OQuestionTableAnswer(isSelected: false,
                                               mark: alphabet[index],
                                               answer: answer.answer ?? "")
            elements.append(.answer(element))
            
            if (question.answers.count - 1) != index {
                elements.append(.offset(12.scale))
            }
        }
        
        tableView.setup(elements: elements, didSelect: completion)
    }
    
    func openError() -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make {
                    observe.onNext(())
                }
                self.vc?.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
}

// MARK: Make constraints
private extension OTestView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -17.scale)
        ])
        
        NSLayoutConstraint.activate([
            favoriteButton.widthAnchor.constraint(equalToConstant: 12.scale),
            favoriteButton.heightAnchor.constraint(equalToConstant: 18.scale),
            favoriteButton.centerYAnchor.constraint(equalTo: progressLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -23.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 98.scale : 70.scale),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OTestView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeFavoriteButton() -> OQuestionFavoriteButton {
        let view = OQuestionFavoriteButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> OQuestionTableView {
        let view = OQuestionTableView()
        view.layer.cornerRadius = 12.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.contentInset = UIEdgeInsets(top: 32.scale, left: 0, bottom: 32.scale, right: 0)
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = Appearance.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 45.scale, height: 45.scale))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
