//
//  PracticeViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import RxSwift
import RxCocoa

final class PracticeViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var activity = RxActivityIndicator()
    
    lazy var elements = makeElements()
    
    private lazy var examDate = makeExamDate()
    private lazy var dailyQiestion = makeDailyQuestion()
    private lazy var testsCount = makeTestsCount()
    private lazy var currentCourse = makeCurrentCourse()
    private lazy var activeSubscription = makeActiveSubscription()
    
    private lazy var sessionManager = SessionManager()
    private lazy var profileManager = ProfileManager()
    private lazy var questionManager = QuestionManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension PracticeViewModel {
    func makeElements() -> Driver<[PracticeTableElement]> {
        Driver
            .combineLatest(examDate, dailyQiestion, testsCount, activeSubscription)
            .map { examDate, dailyQiestion, testsCount, activeSubscription -> [PracticeTableElement] in
                var result = [PracticeTableElement]()
                
                result.append(.examDate(examDate))
                
                if let dailyQiestion = dailyQiestion {
                    result.append(contentsOf: [
                        .offset(32.scale),
                        .title("Practice.DailyQuestion.Title".localized),
                        .offset(16.scale),
                        .dailyQuestion(dailyQiestion)
                    ])
                }
                
                result.append(contentsOf: [
                    .offset(32.scale),
                    .title("Practice.Tests.Title".localized),
                    .offset(16.scale),
                    .tests(testsCount)
                ])
                
                if !activeSubscription {
                    result.append(contentsOf: [
                        .offset(60.scale),
                        .unlockPremium(8500)
                    ])
                }
                
                return result
            }
    }
    
    func makeExamDate() -> Driver<Date?> {
        let initial = profileManager
            .obtainDateOfExam(forceUpdate: false)
            .asDriver(onErrorJustReturn: nil)
        
        let updated = ProfileMediator.shared
            .changedDateOfExam
            .map { examDate -> Date? in
                examDate
            }
            .asDriver(onErrorJustReturn: nil)
        
        return Driver.merge(initial, updated)
    }
    
    func makeDailyQuestion() -> Driver<String?> {
        currentCourse
            .flatMap { [weak self] course -> Driver<String?> in
                guard let self = self else {
                    return .never()
                }
                
                return self.questionManager
                    .obtainQotdTest(courseId: course.id, activeSubscription: false)
                    .map { qotdTest -> String? in
                        qotdTest?.test.questions.first?.question
                    }
                    .asDriver(onErrorJustReturn: nil)
            }
    }
    
    func makeTestsCount() -> Driver<PracticeTableTestsCount> {
        let trigger = QuestionMediator.shared.testPassed
            .asDriver(onErrorDriveWith: .never())
            .startWith(Void())
        
        return Driver
            .combineLatest(trigger, currentCourse) { $1 }
            .flatMap { [weak self] course -> Driver<TestsKit?> in
                guard let self = self else {
                    return .never()
                }
                
                return self.questionManager
                    .obtainTestsKit(courseId: course.id)
                    .asDriver(onErrorJustReturn: nil)
            }
            .compactMap { testsKit -> PracticeTableTestsCount? in
                guard let testsKit = testsKit else {
                    return nil
                }
                
                return PracticeTableTestsCount(random: testsKit.randomCount,
                                               missed: testsKit.missedCount,
                                               quick: testsKit.quickCount,
                                               saved: testsKit.savedCount)
            }
    }
    
    func makeCurrentCourse() -> Driver<Course> {
        let initial = profileManager
            .obtainSelectedCourse(forceUpdate: false)
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
