//
//  MyProfileViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 13.05.2022.
//

import RxSwift
import RxCocoa

final class MyProfileViewModel {
    lazy var elements = makeElements()
    
    private lazy var dateOfExam = makeDateOfExam()
    private lazy var exam = makeExam()
    private lazy var course = makeCourse()
    private lazy var studyMode = makeStudyMode()
    private lazy var dailyGoal = makeDailyGoal()
    
    private lazy var profileManager = ProfileManager()
}

// MARK: Private
private extension MyProfileViewModel {
    func makeElements() -> Driver<[MyProfileTableElement]> {
        Driver
            .combineLatest(
                dateOfExam,
                exam,
                course,
                studyMode,
                dailyGoal
            )
            .map { stub -> [MyProfileTableElement] in
                let (dateOfExam, exam, course, studyMode, dailyGoal) = stub
                
                return [
                    .dateOfExam(dateOfExam),
                    .exams(exam),
                    .course(course),
                    .studyMode(studyMode),
                    .dailyGoal(dailyGoal),
                    .resetProgress
                ]
            }
    }
    
    func makeDateOfExam() -> Driver<String> {
        let initial = profileManager
            .obtainDateOfExam(forceUpdate: false)
            .map { $0 ?? "" }
            .asDriver(onErrorJustReturn: "")
        
        let updated = ProfileMediator.shared
            .changedDateOfExam
            .asDriver(onErrorJustReturn: "")
        
        return Driver.merge(initial, updated)
    }
    
    func makeExam() -> Driver<String> {
        let initial = profileManager
            .obtainSelectedExam()
            .map { $0?.title ?? "" }
            .asDriver(onErrorJustReturn: "")
        
        let updated = ProfileMediator.shared
            .changedExam
            .map { $0.title }
            .asDriver(onErrorJustReturn: "")
        
        return Driver.merge(initial, updated)
    }
    
    func makeCourse() -> Driver<String> {
        let initial = profileManager
            .obtainSelectedCourse()
            .map { $0?.name ?? "" }
            .asDriver(onErrorJustReturn: "")
        
        let updated = ProfileMediator.shared
            .changedCourse
            .map { $0.name }
            .asDriver(onErrorJustReturn: "")
        
        return Driver.merge(initial, updated)
    }
    
    func makeStudyMode() -> Driver<String> {
        let initial = profileManager
            .obtainTestMode(forceUpdate: false)
            .asDriver(onErrorJustReturn: nil)
        
        let updated = ProfileMediator.shared
            .changedTestMode
            .map { mode -> TestMode? in
                mode
            }
            .asDriver(onErrorJustReturn: nil)
        
        return Driver
            .merge(initial, updated)
            .map { mode -> String in
                guard let mode = mode else {
                    return ""
                }
                
                switch mode {
                case .noExplanations:
                    return "MyProfile.StudyMode.WithoutExplanations".localized
                case .fullComplect:
                    return "MyProfile.StudyMode.FullSupport".localized
                case .onAnExam:
                    return "MyProfile.StudyMode.Exam-style".localized
                }
            }
    }
    
    func makeDailyGoal() -> Driver<String> {
        let initial = profileManager
            .obtainTestMinutes(forceUpdate: false)
            .asDriver(onErrorJustReturn: nil)
        
        let updated = ProfileMediator.shared
            .changedTestMinutes
            .map { testMinutes -> Int? in
                testMinutes
            }
            .asDriver(onErrorJustReturn: nil)
        
        return Driver.merge(initial, updated)
            .map { testMinutes -> String in
                guard let testMinutes = testMinutes else {
                    return ""
                }
                
                return String(format: "MyProfile.min".localized, testMinutes)
            }
    }
}
