//
//  StatsViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 02.06.2022.
//

import RxSwift
import RxCocoa

final class StatsViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var activity = RxActivityIndicator()
    
    private lazy var stats = makeStats()
    private lazy var currentCourse = makeCurrentCourse()
    
    private lazy var profileManager = ProfileManager()
    private lazy var statsManager = StatsManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension StatsViewModel {
    func makeStats() -> Driver<Stats> {
        currentCourse
            .flatMapLatest { [weak self] course -> Driver<Stats> in
                guard let self = self else {
                    return .never()
                }
                
                // TODO: Обновлять после прохождения теста
                func source() -> Observable<Stats> {
                    let triggers = Signal
                        .merge(
                            StatsMediator.shared.resetedStats
                        )
                        .asObservable()
                        .startWith(Void())
                    
                    return triggers
                        .flatMapLatest {
                            self.statsManager
                                .obtainStats(for: course.id)
                                .flatMap { stats -> Single<Stats> in
                                    guard let stats = stats else {
                                        return .error(ContentError(.notContent))
                                    }
                                    
                                    return .just(stats)
                                }
                                .trackActivity(self.activity)
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return source()
                    .retry(when: { err in
                        err.flatMapLatest {
                            trigger(error: $0)
                        }
                    })
                    .asDriver(onErrorDriveWith: .never())
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
}
