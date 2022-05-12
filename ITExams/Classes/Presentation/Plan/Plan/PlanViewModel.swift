//
//  PlanViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 30.03.2022.
//

import RxSwift
import RxCocoa

final class PlanViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var currentStep = PublishRelay<StepCollectionElement>()
    
    lazy var tests = makeTests()
    lazy var planSteps = makePlanSteps()
    lazy var planCurrent = makePlanCurrent()
    lazy var planStudyScore = makePlanStudyScore()
    
    lazy var activity = RxActivityIndicator()
    
    private lazy var currentExam = makeCurrentExam()
    private lazy var currentCourse = makeCurrentCourse()
    private lazy var plan = makePlan()
    private lazy var activeSubscription = makeActiveSubscription()
    
    private lazy var profileManager = ProfileManager()
    private lazy var planManager = PlanManager()
    private lazy var sessionManager = SessionManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension PlanViewModel {
    func makeTests() -> Driver<StepTests> {
        let step = currentStep
            .asDriver(onErrorDriveWith: .empty())
        
        return Driver.combineLatest(step, activeSubscription) {
            StepTests(tests: $0.step.tests,
                      activeSubscription: $1,
                      lockedStep: $0.locked)
        }
    }
    
    func makePlanSteps() -> Driver<[StepCollectionElement]> {
        plan.map { plan -> [StepCollectionElement] in
            let steps = plan.steps.sorted(by: { $0.sort < $1.sort })
            let elements = StepCollectionElement.from(steps: steps)
            return elements
        }
    }
    
    func makePlanCurrent() -> Driver<PlanCurrent> {
        Driver
            .combineLatest(currentExam, currentCourse) {
                PlanCurrent(exam: $0, course: $1)
            }
    }
    
    func makePlanStudyScore() -> Driver<PlanStudyScore> {
        plan
            .map { plan -> PlanStudyScore in
                PlanStudyScore(goal: plan.goal, progress: plan.progress)
            }
    }
    
    func makePlan() -> Driver<Plan> {
        currentCourse
            .flatMapLatest { [weak self] course -> Driver<Plan> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Plan> {
                    self.planManager
                        .obtainPlan(for: course.id)
                        .flatMap { plan -> Single<Plan> in
                            guard let plan = plan else {
                                return .error(ContentError(.notContent))
                            }
                            
                            return .just(plan)
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
    
    func makeCurrentExam() -> Driver<Exam> {
        let initial = profileManager
            .obtainSelectedExam()
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let updated = ProfileMediator.shared
            .changedExam
            .asDriver(onErrorDriveWith: .never())
        
        return Driver.merge(initial, updated)
    }
    
    func makeCurrentCourse() -> Driver<Course> {
        let initial = profileManager
            .obtainSelectedCourse()
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let updated = ProfileMediator.shared
            .changedCourse
            .asDriver(onErrorDriveWith: .never())
        
        return Driver.merge(initial, updated)
    }
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .map { [weak self] in
                guard let self = self else {
                    return false
                }
                
                return self.sessionManager.hasActiveSubscriptions()
            }
            .startWith(sessionManager.hasActiveSubscriptions())
            .asDriver(onErrorJustReturn: false)
    }
}
