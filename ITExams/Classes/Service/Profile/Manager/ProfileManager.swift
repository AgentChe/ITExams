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
             testMinutes: Int?,
             exam: Exam?,
             course: Course?) -> Single<Void>
    func obtainExams() -> Single<[Exam]>
    func obtainSelectedExam() -> Single<Exam?>
    func obtainSelectedCourse() -> Single<Course?>
    func obtainTestMode() -> Single<TestMode?>
    func syncTokens(oldToken: String, newToken: String) -> Single<Void>
    func login(userToken: String) -> Single<Void>
}

final class ProfileManager: ProfileManagerProtocol {
    enum Constants {
        static let examKey = "profile_manager_exam_key"
        static let courseKey = "profile_manager_course_key"
    }
    
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionMager = SessionManagerCore()
}

// MARK: Study
extension ProfileManager {
    func set(motivation: Int? = nil,
             examDate: String? = nil,
             testMode: Int? = nil,
             testMinutes: Int? = nil,
             exam: Exam? = nil,
             course: Course? = nil) -> Single<Void> {
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
                self.store(exam: exam)
                self.store(course: course)
            })
    }
    
    func obtainExams() -> Single<[Exam]> {
        Single<[Exam]>
            .create { event in
                let exams = [
                    Exam(code: "AWS",
                         title: "Onboarding.Exams.Exam1.Name".localized,
                         subTitle: "Onboarding.Exams.Exam1.Text".localized,
                         api: GlobalDefinitions.awsApiKey,
                         domain: GlobalDefinitions.awsDomainUrl),
                    Exam(code: "CompTIA",
                         title: "Onboarding.Exams.Exam2.Name".localized,
                         subTitle: "Onboarding.Exams.Exam2.Text".localized,
                         api: GlobalDefinitions.comptiaApiKey,
                         domain: GlobalDefinitions.comptiaDomainUrl),
                    Exam(code: "CISSP",
                         title: "Onboarding.Exams.Exam3.Name".localized,
                         subTitle: "Onboarding.Exams.Exam3.Text".localized,
                         api: GlobalDefinitions.cisspApiKey,
                         domain: GlobalDefinitions.cisspDomainUrl)
                ]
                
                event(.success(exams))
                
                return Disposables.create()
            }
    }
    
    func obtainSelectedExam() -> Single<Exam?> {
        Single<Exam?>
            .create { event in
                guard let data = UserDefaults.standard.data(forKey: Constants.examKey) else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                let exam = try? JSONDecoder().decode(Exam.self, from: data)
                
                event(.success(exam))
                
                return Disposables.create()
            }
    }
    
    func obtainSelectedCourse() -> Single<Course?> {
        Single<Course?>
            .create { event in
                guard let data = UserDefaults.standard.data(forKey: Constants.courseKey) else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                let course = try? JSONDecoder().decode(Course.self, from: data)
                
                event(.success(course))
                
                return Disposables.create()
            }
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
    
    func store(exam: Exam?) {
        guard let exam = exam, let data = try? JSONEncoder().encode(exam) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: Constants.examKey)
    }
    
    func store(course: Course?) {
        guard let course = course, let data = try? JSONEncoder().encode(course) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: Constants.courseKey)
    }
}
