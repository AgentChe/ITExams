//
//  DailyGoalViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 16.05.2022.
//

import RxSwift
import RxCocoa

final class DailyGoalViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var newTestMinutes = PublishRelay<Int>()
    
    lazy var currentTestMinutes = makeCurrentTestMinutes()
    lazy var saved = makeSaved()
    lazy var activity = RxActivityIndicator()
    
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension DailyGoalViewModel {
    func makeCurrentTestMinutes() -> Driver<Int> {
        profileManager
            .obtainTestMinutes(forceUpdate: false)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
    }
    
    func makeSaved() -> Driver<Void> {
        newTestMinutes
            .flatMapLatest { [weak self] testMinutes -> Observable<Void> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Void> {
                    self.profileManager
                        .set(testMinutes: testMinutes)
                        .mapToVoid()
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
            }
            .asDriver(onErrorDriveWith: .never())
    }
}
