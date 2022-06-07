//
//  QuestionManager.swift
//  ITExams
//
//  Created by Андрей Чернышев on 06.06.2022.
//

import RxSwift

protocol QuestionManagerProtocol {
    func obtainOnboardingTest(forceUpdate: Bool) -> Single<Test?>
    func obtainReview(for courseId: Int, mode: Int, offset: Int) -> Single<[Review]>
}

final class QuestionManager: QuestionManagerProtocol {
    enum Constants {
        static let onboardingSetKey = "question_manager_onboarding_test_key"
    }
    
    private lazy var xorRequestWrapper = XORRequestWrapper()
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Public
extension QuestionManager {
    func obtainOnboardingTest(forceUpdate: Bool) -> Single<Test?> {
        forceUpdate ? loadOnboardingTest() : cachedOnboardingTest()
    }
    
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

// MARK: Private
private extension QuestionManager {
    func loadOnboardingTest() -> Single<Test?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetOnboardingTestRequest(userToken: userToken)
        
        return xorRequestWrapper
            .callServerStringApi(requestBody: request, key: GlobalDefinitions.apiKey)
            .map { GetTestResponseMapper.map(from: $0, isEncryption: true) }
            .do(onSuccess: { test in
                guard let test = test, let data = try? JSONEncoder().encode(test) else {
                    return
                }
                
                UserDefaults.standard.set(data, forKey: Constants.onboardingSetKey)
            })
    }
    
    func cachedOnboardingTest() -> Single<Test?> {
        Single<Test?>
            .create { event in
                guard
                    let data = UserDefaults.standard.data(forKey: Constants.onboardingSetKey),
                    let test = try? JSONDecoder().decode(Test.self, from: data)
                else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(test))
                
                return Disposables.create()
            }
    }
}
