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
                                             userToken: sessionManager.internalId,
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
