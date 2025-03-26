//
//  PaygateInteractor.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.03.2022.
//

import RxSwift
import RxCocoa
import OtterScaleiOS

final class PaygateInteractor {
    enum Action {
        case buy(String)
        case restore
    }
    
    enum PurchaseActionResult {
        case cancelled
        case completed(Bool)
    }
    
    private lazy var iapManager = IAPManager()
    private lazy var sessionManager = SessionManager()
    private lazy var profileManager = ProfileManager()
    private lazy var validationObserver = PurchaseValidationObserver.shared
    
    private lazy var disposables = [Disposable]()
    
    private lazy var callback = PublishRelay<PurchaseActionResult>()
    
    deinit {
        OtterScale.shared.removeReceiptValidation(delegate: self)
        
        disposables.forEach { $0.dispose() }
    }
}

// MARK: Public
extension PaygateInteractor {
    func makeActiveSubscription(by action: Action) -> Single<PurchaseActionResult> {
        OtterScale.shared.removeReceiptValidation(delegate: self)
        OtterScale.shared.addReceiptValidation(delegate: self)
        
        disposables.forEach { $0.dispose() }
        
        let disposable: Disposable
        switch action {
        case .buy(let productId):
            disposable = purchase(productId: productId)
        case .restore:
            disposable = restore()
        }
        
        disposables = [disposable]
        
        return Single<PurchaseActionResult>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            let disposable = self.callback.subscribe(onNext: { result in
                event(.success(result))
            })
            
            self.disposables.append(disposable)
            
            return Disposables.create()
        }
    }
}

// MARK: OtterScaleReceiptValidationDelegate
extension PaygateInteractor: OtterScaleReceiptValidationDelegate {
    func otterScaleDidValidatedReceipt(with result: AppStoreValidateResult?) {
        
    }
}

// MARK: Private
private extension PaygateInteractor {
    func purchase(productId: String) -> Disposable {
        iapManager
            .buyProduct(with: productId)
            .subscribe(onSuccess: { [weak self] result in
                guard let self = self, case .cancelled = result else {
                    return
                }
                
                self.callback.accept(.cancelled)
            })
    }
    
    func restore() -> Disposable {
        iapManager
            .restorePurchases()
            .subscribe()
    }
    
    func syncTokens(oldToken: String, newToken: String) -> Single<Void> {
        profileManager
            .obtainExams()
            .flatMap { [weak self] exams -> Single<Void> in
                guard let self = self else {
                    return .never()
                }
                
                let requests = exams
                    .map { exam -> Single<Void> in
                        self.profileManager.syncTokens(domain: exam.domain,
                                                       apiKey: exam.api,
                                                       oldToken: oldToken,
                                                       newToken: newToken)
                    }
                
                return Single
                    .zip(requests)
                    .mapToVoid()
            }
    }
    
    func login(userToken: String) -> Single<Void> {
        profileManager
            .obtainExams()
            .flatMap { [weak self] exams -> Single<Void> in
                guard let self = self else {
                    return .never()
                }
                
                let requests = exams
                    .map { exam -> Single<Void> in
                        self.profileManager.login(domain: exam.domain,
                                                  apiKey: exam.api,
                                                  userToken: userToken)
                    }
                
                return Single
                    .zip(requests)
                    .mapToVoid()
            }
    }
}
