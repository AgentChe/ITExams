//
//  PaygateManager.swift
//  ITExams
//
//  Created by Андрей Чернышев on 29.03.2022.
//

import RxSwift
import OtterScaleiOS

protocol PaygateManagerProtocol {
    func obtainMonetization(forceUpdate: Bool) -> Single<Monetization?>
    func obtainPaygate(forceUpdate: Bool) -> Single<Paygate?>
}

final class PaygateManager: PaygateManagerProtocol {
    enum Constants {
        static let monetizationKey = "paygate_manager_monetization_key"
        static let paygateKey = "paygate_manager_paygate_key"
    }
    
    private let defaultRequestWrapper = DefaultRequestWrapper()
    private let sessionManager = SessionManager()
}

// MARK: Public
extension PaygateManager {
    func obtainMonetization(forceUpdate: Bool = false) -> Single<Monetization?> {
        forceUpdate ? loadAndStoreMonetization() : localMonetization()
    }
    
    func obtainPaygate(forceUpdate: Bool) -> Single<Paygate?> {
        forceUpdate ? loadPaygate() : cachedPaygate()
    }
}

// MARK: Private
private extension PaygateManager {
    func localMonetization() -> Single<Monetization?> {
        Single<Monetization?>
            .create { event in
                var monetization: Monetization?
                
                if let rawValue = UserDefaults.standard.string(forKey: Constants.monetizationKey) {
                    monetization = Monetization(rawValue: rawValue)
                }
                
                event(.success(monetization))
                
                return Disposables.create()
            }
    }
    
    func loadAndStoreMonetization() -> Single<Monetization?> {
        let request = GetMonetizationRequest(userToken: sessionManager.getSession()?.userToken,
                                             version: UIDevice.appVersion ?? "1",
                                             appAnonymousId: OtterScale.shared.getAnonymousID())
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { try GetMonetizationResponseMapper.map(from: $0) }
            .flatMap { [weak self] monetization -> Single<Monetization?> in
                guard let self = self else {
                    return .never()
                }
                
                return self.store(monetization: monetization)
            }
    }
    
    func store(monetization: Monetization?) -> Single<Monetization?> {
        Single<Monetization?>
            .create { event in
                guard let rawValue = monetization?.rawValue else {
                    event(.success(monetization))
                    return Disposables.create()
                }
        
                UserDefaults.standard.setValue(rawValue, forKey: Constants.monetizationKey)
                
                event(.success(monetization))
                
                return Disposables.create()
            }
    }
    
    func loadPaygate() -> Single<Paygate?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let usedProducts = OtterScale.shared.getUsedProducts()
            .map { products -> [String] in
                products.appleAppStore + products.googlePlay + products.stripe
            }
        
        let request = GetPaygateRequest(userToken: userToken,
                                        userProducts: usedProducts ?? [])
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetPaygateResponse.map(response: $0) }
            .do(onSuccess: { paygate in
                guard let paygate = paygate, let data = try? JSONEncoder().encode(paygate) else {
                    return
                }
                
                UserDefaults.standard.set(data, forKey: Constants.paygateKey)
            })
    }
    
    func cachedPaygate() -> Single<Paygate?> {
        Single<Paygate?>
            .create { event in
                guard
                    let data = UserDefaults.standard.data(forKey: Constants.paygateKey),
                    let paygate = try? JSONDecoder().decode(Paygate.self, from: data)
                else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(paygate))
                
                return Disposables.create()
            }
    }
}
