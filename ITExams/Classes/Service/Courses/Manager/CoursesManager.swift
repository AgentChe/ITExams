//
//  CoursesManagerCore.swift
//  Nursing
//
//  Created by Andrey Chernyshev on 17.01.2021.
//

import RxSwift

protocol CoursesManagerProtocol: AnyObject {
    func obtainCourses(domain: String, apiKey: String) -> Single<[Course]>
}

final class CoursesManager: CoursesManagerProtocol {
    enum Constants {
        static let courseKey = "courses_manager_course_key"
    }
    
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Public
extension CoursesManager {
    func obtainCourses(domain: String, apiKey: String) -> Single<[Course]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .deferred { .just([]) }
        }
        
        let request = GetCourcesRequest(domain: domain,
                                        apiKey: apiKey,
                                        userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { try GetCourcesResponseMapper.map(from: $0) }
    }
}
