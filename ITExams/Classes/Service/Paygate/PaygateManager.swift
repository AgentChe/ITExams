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
    func obtainPaygate(domain: String, apiKey: String) -> Single<Paygate?>
}

final class PaygateManager: PaygateManagerProtocol {
    enum Constants {
        static let monetizationKey = "paygate_manager_monetization_key"
    }
    
    private let defaultRequestWrapper = DefaultRequestWrapper()
    private let sessionManager = SessionManager()
}

// MARK: Public
extension PaygateManager {
    func obtainMonetization(forceUpdate: Bool = false) -> Single<Monetization?> {
        forceUpdate ? loadAndStoreMonetization() : localMonetization()
    }
    
    func obtainPaygate(domain: String, apiKey: String) -> Single<Paygate?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let usedProducts = OtterScale.shared.getUsedProducts()
            .map { products -> [String] in
                products.appleAppStore + products.googlePlay + products.stripe
            }
        
        let request = GetPaygateRequest(domain: domain,
                                        apiKey: apiKey,
                                        userToken: userToken,
                                        userProducts: usedProducts ?? [])
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetPaygateResponse.map(response: $0) }
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
        let request = GetMonetizationRequest(domain: GlobalDefinitions.awsDomainUrl,
                                             apiKey: GlobalDefinitions.awsApiKey,
                                             userToken: sessionManager.getSession()?.userToken,
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
}
