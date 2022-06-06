//
//  QuestionManager.swift
//  ITExams
//
//  Created by Андрей Чернышев on 06.06.2022.
//

import RxSwift

protocol QuestionManagerProtocol {
    func obtainReview(for courseId: Int, mode: Int, offset: Int) -> Single<[Review]>
}

final class QuestionManager: QuestionManagerProtocol {
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Public
extension QuestionManager {
    func obtainReview(for courseId: Int, mode: Int, offset: Int) -> Single<[Review]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetReviewRequest(userToken: userToken,
                                       courseId: courseId,
                                       mode: mode,
                                       offset: offset)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetReviewResponse.map(from: $0) }
    }
}
