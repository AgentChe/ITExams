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
    
    // TODO
    func makeDateOfExam() -> Driver<String> {
        .deferred {
            .just("Feb 15, 2022")
        }
    }
    
    // TODO
    func makeExam() -> Driver<String> {
        profileManager
            .obtainSelectedExam()
            .compactMap { $0?.title }
            .asDriver(onErrorDriveWith: .empty())
    }
    
    // TODO
    func makeCourse() -> Driver<String> {
        profileManager
            .obtainSelectedCourse()
            .compactMap { $0?.name }
            .asDriver(onErrorDriveWith: .empty())
    }
    
    // TODO: activity
    func makeStudyMode() -> Driver<String> {
        profileManager
            .obtainTestMode()
            .compactMap { mode -> String? in
                guard let mode = mode else {
                    return nil
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
            .asDriver(onErrorDriveWith: .empty())
    }
    
    // TODO
    func makeDailyGoal() -> Driver<String> {
        .deferred {
            .just("3 min")
        }
    }
}
