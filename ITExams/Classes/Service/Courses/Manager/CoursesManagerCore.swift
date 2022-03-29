//
//  CoursesManagerCore.swift
//  Nursing
//
//  Created by Andrey Chernyshev on 17.01.2021.
//

import RxSwift

protocol CoursesManagerProtocol: AnyObject {
    func retrieveCourses(domain: String, apiKey: String) -> Single<[Course]>
}

final class CoursesManager: CoursesManagerProtocol {
    enum Constants {
        static let courseKey = "courses_manager_course_key"
    }
}

// MARK: Public
extension CoursesManager {
    func retrieveCourses(domain: String, apiKey: String) -> Single<[Course]> {
        guard let userToken = SessionManagerCore().getSession()?.userToken else {
            return .deferred { .just([]) }
        }
        
        let request = GetCourcesRequest(domain: domain,
                                        apiKey: apiKey,
                                        userToken: userToken)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(GetCourcesResponseMapper.map(from:))
    }
}
