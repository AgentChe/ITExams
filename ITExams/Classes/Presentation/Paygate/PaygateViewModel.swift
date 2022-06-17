//
//  PaygateViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.03.2022.
//

import RxSwift
import RxCocoa

final class PaygateViewModel {
    enum Constants {
        static let monthlyTrial = "prepbundle.it.monthly_trial"
        static let monthly = "prepbundle.it.monthly"
        static let lifetime = "prepbundle.it.lifetime"
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    let buy = PublishRelay<String>()
    let restore = PublishRelay<Void>()

    lazy var paygate = makePaygate()
    lazy var monetization = makeMonetization()
    lazy var prices = makePrices()
    lazy var buyed = makeBuyed()
    lazy var restored = makeRestored()
    
    let activityIndicator = RxActivityIndicator()
    
    private lazy var iapManager = IAPManager()
    private lazy var purchaseInteractor = PaygateInteractor()
    private lazy var paygateManager = PaygateManager()
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension PaygateViewModel {
    func makePaygate() -> Driver<Paygate> {
        profileManager
            .obtainExamEnvironment()
            .asObservable()
            .flatMap { [weak self] examEnvironment -> Observable<Paygate?> in
                guard let self = self, let examEnvironment = examEnvironment else {
                    return .never()
                }
                
                func source() -> Single<Paygate?> {
                    self.paygateManager
                        .obtainPaygate(domain: examEnvironment.exam.domain,
                                       apiKey: examEnvironment.exam.api)
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
                    .trackActivity(self.activityIndicator)
            }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeMonetization() -> Driver<Monetization> {
        paygateManager
            .obtainMonetization()
            .asDriver(onErrorJustReturn: nil)
            .map { $0 ?? .suggest }
    }
    
    func makePrices() -> Driver<[PaygatePrice]> {
        iapManager
            .obtainPrices(for: [
                Constants.lifetime, Constants.monthly, Constants.monthlyTrial
            ])
            .map { prices -> [PaygatePrice] in
                prices.compactMap { price -> PaygatePrice? in
                    switch price.id {
                    case Constants.lifetime:
                        return PaygatePrice(product: .lifetime, price: price)
                    case Constants.monthly:
                        return PaygatePrice(product: .monthly, price: price)
                    case Constants.monthlyTrial:
                        return PaygatePrice(product: .monthlyTrial, price: price)
                    default:
                        return nil
                    }
                }
            }
            .trackActivity(activityIndicator)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeBuyed() -> Signal<Bool> {
        let purchase = buy
            .flatMapLatest { [weak self] productId -> Observable<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                return self.purchaseInteractor
                    .makeActiveSubscription(by: .buy(productId))
                    .map { result -> Bool in
                        switch result {
                        case .completed(let response):
                            return response
                        case .cancelled:
                            return false
                        }
                    }
                    .trackActivity(self.activityIndicator)
                    .catchAndReturn(false)
            }
        
        return purchase
            .asSignal(onErrorJustReturn: false)
    }
    
    func makeRestored() -> Signal<Bool> {
        let purchase = restore
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                return self.purchaseInteractor
                    .makeActiveSubscription(by: .restore)
                    .map { result -> Bool in
                        switch result {
                        case .completed(let response):
                            return response
                        case .cancelled:
                            return false
                        }
                    }
                    .trackActivity(self.activityIndicator)
                    .catchAndReturn(false)
            }
        
        return purchase
            .asSignal(onErrorJustReturn: false)
    }
}
