//
//  ProfileManagerCore.swift
//  FNP
//
//  Created by Andrey Chernyshev on 09.07.2021.
//

import RxSwift

protocol ProfileManagerProtocol {
    func set(motivation: Int?,
             examDate: String?,
             testMode: Int?,
             testMinutes: Int?) -> Single<Void>
    func obtainTestMode() -> Single<TestMode?>
    func syncTokens(oldToken: String, newToken: String) -> Single<Void>
    func login(userToken: String) -> Single<Void>
}

final class ProfileManager: ProfileManagerProtocol {
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionMager = SessionManagerCore()
}

// MARK: Study
extension ProfileManager {
    func set(motivation: Int? = nil,
             examDate: String? = nil,
             testMode: Int? = nil,
             testMinutes: Int? = nil) -> Single<Void> {
        guard let userToken = sessionMager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SetRequest(userToken: userToken,
                                 level: motivation,
                                 testMode: testMode,
                                 examDate: examDate,
                                 testMinutes: testMinutes)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.notifyAboutChanged(testMode: testMode)
            })
    }
    
    func obtainTestMode() -> Single<TestMode?> {
        guard let userToken = sessionMager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetTestModeRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map(GetTestModeResponseMapper.map(from:))
    }
    
    func syncTokens(oldToken: String, newToken: String) -> Single<Void> {
        let request = SyncTokensRequest(oldToken: oldToken, newToken: newToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
    
    func login(userToken: String) -> Single<Void> {
        defaultRequestWrapper
            .callServerApi(requestBody: LoginRequest(userToken: userToken))
            .mapToVoid()
    }
}

// MARK: Private
private extension ProfileManager {
    func notifyAboutChanged(testMode: Int?) {
        if let testMode = testMode, let mode = GetTestModeResponseMapper.map(testModeCode: testMode) {
            ProfileMediator.shared.notifyAboutChanged(testMode: mode)
        }
    }
}
