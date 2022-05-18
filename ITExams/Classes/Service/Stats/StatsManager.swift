//
//  StatsManager.swift
//  ITExams
//
//  Created by Андрей Чернышев on 18.05.2022.
//

import RxSwift

protocol StatsManagerProtocol {
    func resetStats(for courseId: Int) -> Single<Void>
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
}
