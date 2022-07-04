//
//  ExamAndCourseViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 04.07.2022.
//

import UIKit
import RxSwift

final class ExamAndCourseViewController: UIViewController {
    lazy var mainView = ExamAndCourseView()
    
    private lazy var viewModel = ExamAndCourseViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var mode = Mode.exam
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.openError()
        }
        
        viewModel.saved
            .drive(Binder(self) { base, void in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
            })
            .disposed(by: disposeBag)
        
        viewModel.elements
            .drive(Binder(self) { base, elements in
                base.mainView.tableView.setup(elements: elements)
                base.changeEnabled()
            })
            .disposed(by: disposeBag)
        
        mainView.button.rx.tap
            .bind(to: Binder(self) { base, void in
                base.nextTapped()
            })
            .disposed(by: disposeBag)
        
        mainView.backButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.backTapped()
            })
            .disposed(by: disposeBag)
        
        updateMainView()
        changeEnabled()
        mainView.tableView.mainDelegate = self
    }
}

// MARK: Make
extension ExamAndCourseViewController {
    static func make() -> ExamAndCourseViewController {
        ExamAndCourseViewController()
    }
}

// MARK: ExamAndCourseTableDelegate
extension ExamAndCourseViewController: ExamAndCourseTableDelegate {
    func examsAndCourseTableDidChangeSelected() {
        changeEnabled()
    }
}

// MARK: Private
private extension ExamAndCourseViewController {
    private enum Mode {
        case exam, course
    }
    
    func nextTapped() {
        switch mode {
        case .exam:
            mode = .course
            
            updateMainView()
            
            let exams = mainView.tableView.elements.compactMap { element -> Exam? in
                guard
                    let examElement = element as? EACExamElement,
                    examElement.isSelected
                else {
                    return nil
                }
                
                return examElement.element
            }
            
            if let exam = exams.first {
                viewModel.selectExam.accept(exam)
            }
            
            mainView.tableView.setup(elements: [])
            changeEnabled()
        case .course:
            let courses = mainView.tableView.elements.compactMap { element -> Course? in
                guard
                    let courseElement = element as? EACCourseElement,
                    courseElement.isSelected
                else {
                    return nil
                }
                
                return courseElement.element
            }
            
            if let course = courses.first {
                viewModel.selectCourse.accept(course)
            }
        }
    }
    
    func backTapped() {
        mode = .exam
        
        updateMainView()
        
        viewModel.backTapped.accept(Void())
    }
    
    func updateMainView() {
        mainView.update(asExamMode: mode == .exam)
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
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
    
    func activity(_ activity: Bool) {
        mainView.button.isHidden = activity
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
    
    func changeEnabled() {
        let isSelected = mainView.tableView.elements.contains(where: { $0.isSelected })
        
        mainView.button.isEnabled = isSelected
        mainView.button.alpha = isSelected ? 1 : 0.2
    }
}
