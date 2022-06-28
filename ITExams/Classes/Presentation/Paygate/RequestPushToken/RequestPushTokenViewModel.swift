//
//  RequestPushTokenViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 28.06.2022.
//

import RxSwift
import RxCocoa

final class RequestPushTokenViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var newToken = PublishRelay<String>()
    
    lazy var saved = makeSaved()
    lazy var activity = RxActivityIndicator()
    
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension RequestPushTokenViewModel {
    func makeSaved() -> Driver<Void> {
        newToken
            .flatMapLatest { [weak self] token -> Observable<Void> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Void> {
                    self.profileManager
                        .obtainExams()
                        .flatMap { [weak self] exams -> Single<Void> in
                            guard let self = self else {
                                return .never()
                            }
                            
                            let requests = exams
                                .map { exam -> Single<Void> in
                                    self.profileManager.set(domain: exam.domain,
                                                            apiKey: exam.api,
                                                            pushToken: token)
                                }
                            
                            return Single
                                .zip(requests)
                                .mapToVoid()
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
            }
            .asDriver(onErrorDriveWith: .never())
    }
}
