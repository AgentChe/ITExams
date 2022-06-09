//
//  StatsManager.swift
//  ITExams
//
//  Created by Андрей Чернышев on 18.05.2022.
//

import RxSwift

protocol StatsManagerProtocol {
    func resetStats(for courseId: Int) -> Single<Void>
    func obtainStats(for courseId: Int) -> Single<Stats?>
    func obtainTestStats(userTestId: Int) -> Single<TestStats?>
}

final class StatsManager: StatsManagerProtocol {
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Public
extension StatsManager {
    func resetStats(for courseId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = ResetStatsRequest(userToken: userToken, courseId: courseId)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                StatsMediator.shared.notifyAboutResetedStats()
            })
    }
    
    func obtainStats(for courseId: Int) -> Single<Stats?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetStatsRequest(userToken: userToken, courseId: courseId)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { try GetStatsResponseMapper.map(from: $0) }
    }
    
    func obtainTestStats(userTestId: Int) -> Single<TestStats?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetTestStatsRequest(userToken: userToken,
                                          userTestId: userTestId,
                                          peek: true)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetTestStatsResponseMapper.map(from: $0) }
    }
}
