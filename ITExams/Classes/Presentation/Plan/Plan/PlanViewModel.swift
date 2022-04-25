//
//  PlanViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 30.03.2022.
//

import RxSwift
import RxCocoa

final class PlanViewModel {
    lazy var planCurrent = makePlanCurrent()
    lazy var planStudyScore = makePlanStudyScore()
    
    private lazy var plan = makePlan()
    
    private lazy var profileManager = ProfileManager()
    private lazy var planManager = PlanManager()
}

// MARK: Private
private extension PlanViewModel {
    func makePlanCurrent() -> Driver<PlanCurrent> {
        let examInitial = profileManager
            .obtainSelectedExam()
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let examUpdated = ProfileMediator.shared
            .changedExam
            .asDriver(onErrorDriveWith: .never())
        
        let exam = Driver.merge(examInitial, examUpdated)
        
        let courseInitial = profileManager
            .obtainSelectedCourse()
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let courseUpdated = ProfileMediator.shared
            .changedCourse
            .asDriver(onErrorDriveWith: .never())
        
        let course = Driver.merge(courseInitial, courseUpdated)
        
        return Driver
            .combineLatest(exam, course) {
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
        planManager
            .obtainPlan()
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
    }
}
