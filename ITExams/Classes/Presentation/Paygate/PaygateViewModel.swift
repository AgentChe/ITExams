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
        static let lifetime = "exam.nursing.lifetime"
        static let monthly = "exam.nursing.monthly"
    }
    
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
}

// MARK: Private
private extension PaygateViewModel {
    func makePaygate() -> Driver<Paygate> {
        paygateManager
            .obtainPaygate(forceUpdate: false)
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
                Constants.lifetime, Constants.monthly
            ])
            .map { prices -> [PaygatePrice] in
                prices.compactMap { price -> PaygatePrice? in
                    switch price.id {
                    case Constants.lifetime:
                        return PaygatePrice(product: .lifetime, price: price)
                    case Constants.monthly:
                        return PaygatePrice(product: .subscription, price: price)
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
