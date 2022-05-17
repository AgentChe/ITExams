//
//  PlanViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 30.03.2022.
//

import UIKit
import RxSwift

final class PlanViewController: UIViewController {
    lazy var mainView = PlanView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = PlanViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.planSteps
            .drive(onNext: { [weak self] planSteps in
                guard let self = self else {
                    return
                }
                
                self.mainView.stepCollectionView.setup(elements: planSteps)
                self.determineCurrentStep(elements: planSteps)
            })
            .disposed(by: disposeBag)
        
        viewModel.stepContent
            .drive(onNext: { [weak self] stepContent in
                guard let self = self else {
                    return
                }
                
                self.handle(stepContent: stepContent)
            })
            .disposed(by: disposeBag)
        
        viewModel.planCurrent
            .drive(onNext: { [weak self] current in
                guard let self = self else {
                    return
                }

                self.mainView.headerView.currentView.setup(exam: current.exam,
                                                           course: current.course)
            })
            .disposed(by: disposeBag)

        viewModel.planStudyScore
            .drive(onNext: { [weak self] studyScore in
                guard let self = self else {
                    return
                }

                self.mainView.headerView.studyScoreView.setup(goal: studyScore.goal,
                                                              progress: studyScore.progress)
            })
            .disposed(by: disposeBag)
        
        mainView.headerView.currentView.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                
                let vc = CoursesViewController.make()
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.openError()
        }
        
        viewModel.activity
            .drive(onNext: { [weak self] activity in
                guard let self = self else {
                    return
                }
                
                self.activity(activity)
            })
            .disposed(by: disposeBag)
        
        mainView.stepCollectionView.mainDelegate = self
        mainView.testsTableView.mainDelegate = self
    }
}

// MARK: Make
extension PlanViewController {
    static func make() -> PlanViewController {
        PlanViewController()
    }
}

// MARK: StepCollectionViewDelegate
extension PlanViewController: StepCollectionViewDelegate {
    func stepCollectionViewDidSelect(element: StepCollectionElement) {
        update(stepName: element.name())
        viewModel.currentStep.accept(element)
    }
}

// MARK: StepTestsTableViewDelegate
extension PlanViewController: StepTestsTableViewDelegate {
    func stepTestsTableDidSelect(element: PlanTest, activeSubscription: Bool, lockedStep: Bool) {
        guard !lockedStep else {
            return
        }
        
        let needPayment = activeSubscription ? false : element.paid
        
        if needPayment {
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        } else {
            // TODO: Open test
        }
    }
}

// MARK: Private
private extension PlanViewController {
    func handle(stepContent: StepContent) {
        func hiddenTable(_ hidden: Bool) {
            mainView.testsTableView.isHidden = hidden
            mainView.finalStepView.isHidden = !hidden
        }
        
        switch stepContent {
        case .tests(let stepTests):
            mainView.testsTableView.setup(elements: stepTests.tests,
                                          activeSubscription: stepTests.activeSubscription,
                                          lockedStep: stepTests.lockedStep)
            hiddenTable(false)
        case .finalStep(let finalStep, let locked):
            mainView.finalStepView.setup(finalStep: finalStep, locked: locked)
            hiddenTable(true)
        }
    }
    
    func determineCurrentStep(elements: [StepCollectionElement]) {
        guard let index = StepCollectionElement.currentIndex(in: elements) else {
            return
        }
        
        let element = elements[index]
        
        stepCollectionViewDidSelect(element: element)
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
        let showAnimating = activity && mainView.stepCollectionView.elements.isEmpty
        showAnimating ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
        mainView.stepCollectionView.isHidden = showAnimating
        mainView.stepNameLabel.isHidden = showAnimating
        mainView.testsTableView.isHidden = showAnimating
    }
    
    func update(stepName: String) {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.bold(size: 24.scale))
            .lineHeight(28.8.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        mainView.stepNameLabel.attributedText = stepName.attributed(with: attrs)
    }
}
