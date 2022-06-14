//
//  QuestionManager.swift
//  ITExams
//
//  Created by Андрей Чернышев on 06.06.2022.
//

import RxSwift

protocol QuestionManagerProtocol {
    func obtainTest(courseId: Int, testId: Int?, time: Int?, activeSubscription: Bool) -> Single<Test?>
    func obtainTenTest(courseId: Int, activeSubscription: Bool) -> Single<Test?>
    func obtainFailedTest(courseId: Int, activeSubscription: Bool) -> Single<Test?>
    func obtainQotdTest(courseId: Int, activeSubscription: Bool) -> Single<QotdTest?>
    func obtainRandomTest(courseId: Int, activeSubscription: Bool) -> Single<Test?>
    func obtainSavedTest(courseId: Int, activeSubscription: Bool) -> Single<Test?>
    func obtainPlanTest(testId: Int) -> Single<Test?>
    func obtainOnboardingTest(forceUpdate: Bool) -> Single<Test?>
    func obtainReview(for courseId: Int, mode: Int, offset: Int) -> Single<[Review]>
    func saveQuestion(questionId: Int) -> Single<Void>
    func removeSavedQuestion(questionId: Int) -> Single<Void>
    func obtainAgainTest(userTestId: Int) -> Single<Test?>
    func finishTest(userTestId: Int) -> Single<Void>
    func sendAnswer(questionId: Int, userTestId: Int, answerIds: [Int]) -> Single<Bool?>
}

final class QuestionManager: QuestionManagerProtocol {
    enum Constants {
        static func qotdTestKey(courseId: Int) -> String {
            String(format: "%@_%i", "question_manager_qotd_test_key", courseId)
        }
        static let onboardingSetKey = "question_manager_onboarding_test_key"
    }
    
    private lazy var xorRequestWrapper = XORRequestWrapper()
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Public
extension QuestionManager {
    func obtainTest(courseId: Int, testId: Int?, time: Int?, activeSubscription: Bool) -> Single<Test?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetTestRequest(
            userToken: userToken,
            courseId: courseId,
            testId: testId,
            time: time,
            activeSubscription: activeSubscription
        )
        
        return xorRequestWrapper
            .callServerStringApi(requestBody: request, key: GlobalDefinitions.apiKey)
            .map { GetTestResponseMapper.map(from: $0, isEncryption: true) }
    }
    
    func obtainTenTest(courseId: Int, activeSubscription: Bool) -> Single<Test?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetTenTestRequest(userToken: userToken,
                                        courseId: courseId,
                                        activeSubscription: activeSubscription)
        
        return xorRequestWrapper
            .callServerStringApi(requestBody: request, key: GlobalDefinitions.apiKey)
            .map { GetTestResponseMapper.map(from: $0, isEncryption: true) }
    }
    
    func obtainFailedTest(courseId: Int, activeSubscription: Bool) -> Single<Test?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetFailedTestRequest(userToken: userToken,
                                           courseId: courseId,
                                           activeSubscription: activeSubscription)
        
        return xorRequestWrapper
            .callServerStringApi(requestBody: request, key: GlobalDefinitions.apiKey)
            .map { GetTestResponseMapper.map(from: $0, isEncryption: true) }
    }
    
    func obtainQotdTest(courseId: Int, activeSubscription: Bool) -> Single<QotdTest?> {
        cachedQotdTest(courseId: courseId)
            .flatMap { [weak self] test -> Single<QotdTest?> in
                guard let self = self else {
                    return .never()
                }
                
                if let test = test, Calendar.current.isDateInToday(test.creation) {
                    return .just(test)
                }
                
                return self.loadQotdTest(courseId: courseId, activeSubscription: activeSubscription)
            }
    }
    
    func obtainRandomTest(courseId: Int, activeSubscription: Bool) -> Single<Test?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetRandomTestRequest(userToken: userToken,
                                           courseId: courseId,
                                           activeSubscription: activeSubscription)
        
        return xorRequestWrapper
            .callServerStringApi(requestBody: request, key: GlobalDefinitions.apiKey)
            .map { GetTestResponseMapper.map(from: $0, isEncryption: true) }
    }
    
    func obtainSavedTest(courseId: Int, activeSubscription: Bool) -> Single<Test?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetSavedTestRequest(userToken: userToken,
                                          courseId: courseId,
                                          activeSubscription: activeSubscription)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetTestResponseMapper.map(from: $0, isEncryption: false) }
    }
    
    func obtainPlanTest(testId: Int) -> Single<Test?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetPlanTestRequest(userToken: userToken,
                                         testId: testId)
        
        return xorRequestWrapper
            .callServerStringApi(requestBody: request, key: GlobalDefinitions.apiKey)
            .map { GetTestResponseMapper.map(from: $0, isEncryption: true) }
    }
    
    func obtainOnboardingTest(forceUpdate: Bool) -> Single<Test?> {
        forceUpdate ? loadOnboardingTest(encryptionKey: GlobalDefinitions.apiKey) : cachedOnboardingTest()
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
    
    func saveQuestion(questionId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SaveQuestionRequest(userToken: userToken,
                                          questionId: questionId)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
    
    func removeSavedQuestion(questionId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = RemoveSavedQuestionRequest(userToken: userToken,
                                                 questionId: questionId)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
    
    func obtainAgainTest(userTestId: Int) -> Single<Test?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = AgainTestRequest(userToken: userToken,
                                       userTestId: userTestId)
        
        return xorRequestWrapper
            .callServerStringApi(requestBody: request, key: GlobalDefinitions.apiKey)
            .map { GetTestResponseMapper.map(from: $0, isEncryption: true) }
    }
    
    func finishTest(userTestId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = FinishTestRequest(userToken: userToken,
                                        userTestId: userTestId)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
    
    func sendAnswer(questionId: Int, userTestId: Int, answerIds: [Int]) -> Single<Bool?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SendAnswerRequest(
            userToken: userToken,
            questionId: questionId,
            answerIds: answerIds,
            userTestId: userTestId
        )
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { SendAnswerResponseMapper.map(from: $0) }
            .do(onSuccess: { isEndOfTest in
                if isEndOfTest == true {
                    QuestionMediator.shared.notidyAboutTestPassed()
                }
            })
    }
}

// MARK: Private
private extension QuestionManager {
    func loadOnboardingTest(encryptionKey: String) -> Single<Test?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetOnboardingTestRequest(userToken: userToken)
        
        return xorRequestWrapper
            .callServerStringApi(requestBody: request, key: encryptionKey)
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
    
    func loadQotdTest(courseId: Int, activeSubscription: Bool) -> Single<QotdTest?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetQotdTestRequest(userToken: userToken,
                                         courseId: courseId,
                                         activeSubscription: activeSubscription)
        
        return xorRequestWrapper
            .callServerStringApi(requestBody: request, key: GlobalDefinitions.apiKey)
            .map { GetTestResponseMapper.map(from: $0, isEncryption: true) }
            .map { test -> QotdTest? in
                guard let test = test else {
                    return nil
                }
                
                return QotdTest(creation: Date(), test: test)
            }
            .do(onSuccess: { test in
                guard let test = test, let data = try? JSONEncoder().encode(test) else {
                    return
                }
                
                UserDefaults.standard.set(data, forKey: Constants.qotdTestKey(courseId: courseId))
            })
    }
    
    func cachedQotdTest(courseId: Int) -> Single<QotdTest?> {
        Single<QotdTest?>
            .create { event in
                guard
                    let data = UserDefaults.standard.data(forKey: Constants.qotdTestKey(courseId: courseId)),
                    let test = try? JSONDecoder().decode(QotdTest.self, from: data)
                else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(test))
                
                return Disposables.create()
            }
    }
}
