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
    private lazy var activeSubscription = makeActiveSubscription()
    
    private lazy var sessionManager = SessionManager()
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension PracticeViewModel {
    func makeElements() -> Driver<[PracticeTableElement]> {
        Driver
            .combineLatest(examDate, activeSubscription)
            .map { examDate, activeSubscription -> [PracticeTableElement] in
                var result = [PracticeTableElement]()
                
                result.append(.examDate(examDate))
                
                result.append(contentsOf: [
                    .offset(32.scale),
                    .title("Practice.DailyQuestion.Title".localized),
                    .offset(16.scale),
                    .dailyQuestion("What cryptographic hash function is a common hashing algorithm that produced a 128-bit hash and was designed by Ron Rivest in 1992?")
                ])
                
                let testsCount = PracticeTableTestsCount(random: 40,
                                                         missed: 40,
                                                         quick: 40,
                                                         saved: 0)
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
