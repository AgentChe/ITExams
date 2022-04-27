//
//  PlanManager.swift
//  ITExams
//
//  Created by Андрей Чернышев on 30.03.2022.
//

import RxSwift

protocol PlanManagerProtocol {
    func obtainPlan() -> Single<Plan?>
}

final class PlanManager: PlanManagerProtocol {
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Public
extension PlanManager {
    func obtainPlan() -> Single<Plan?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetPlanRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetPlanResponseMapper.map(from: $0) }
    }
}
