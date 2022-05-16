//
//  ProfileManagerCore.swift
//  FNP
//
//  Created by Andrey Chernyshev on 09.07.2021.
//

import RxSwift
import Foundation

protocol ProfileManagerProtocol {
    func set(motivation: Int?,
             examDate: String?,
             testMode: TestMode?,
             testMinutes: Int?) -> Single<Void>
    func set(exam: Exam?, course: Course?) -> Single<Void>
    func obtainDateOfExam(forceUpdate: Bool) -> Single<String?>
    func obtainExams() -> Single<[Exam]>
    func obtainSelectedExam() -> Single<Exam?>
    func obtainSelectedCourse() -> Single<Course?>
    func obtainTestMode(forceUpdate: Bool) -> Single<TestMode?>
    func obtainTestMinutes(forceUpdate: Bool) -> Single<Int?>
    func syncTokens(oldToken: String, newToken: String) -> Single<Void>
    func login(userToken: String) -> Single<Void>
}

final class ProfileManager: ProfileManagerProtocol {
    enum Constants {
        static let dateOfExamKey = "profile_manager_date_of_exam_key"
        static let examKey = "profile_manager_exam_key"
        static let courseKey = "profile_manager_course_key"
        static let testModeKey = "profile_manager_test_mode_key"
        static let testMinutesKey = "profile_manager_test_minutes_key"
    }
    
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Study
extension ProfileManager {
    func set(motivation: Int? = nil,
             examDate: String? = nil,
             testMode: TestMode? = nil,
             testMinutes: Int? = nil) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SetRequest(userToken: userToken,
                                 level: motivation,
                                 testMode: testMode?.code(),
                                 examDate: examDate,
                                 testMinutes: testMinutes)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.store(dateOfExam: examDate)
                self.store(testMode: testMode)
                self.store(testMinutes: testMinutes)
            })
    }
    
    func set(exam: Exam?, course: Course?) -> Single<Void> {
        Single<Void>.create { [weak self] event in
            guard let self = self else {
                event(.success(Void()))
                return Disposables.create()
            }
            
            self.store(exam: exam)
            self.store(course: course)
            
            event(.success(Void()))
            
            return Disposables.create()
        }
    }
    
    func obtainDateOfExam(forceUpdate: Bool) -> Single<String?> {
        forceUpdate ? loadDateOfExam() : cachedDateOfExam()
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
    
    func obtainTestMode(forceUpdate: Bool) -> Single<TestMode?> {
        forceUpdate ? loadTestMode() : cachedTestMode()
    }
    
    func obtainTestMinutes(forceUpdate: Bool) -> Single<Int?> {
        forceUpdate ? loadTestMinutes() : cachedTestMinutes()
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
    func store(dateOfExam: String?) {
        guard let dateOfExam = dateOfExam else {
            return
        }
        
        UserDefaults.standard.set(dateOfExam, forKey: Constants.dateOfExamKey)
        
        ProfileMediator.shared.notifyAboutChanged(dateOfExam: dateOfExam)
    }
    
    func cachedDateOfExam() -> Single<String?> {
        Single<String?>
            .create { event in
                guard let dateOfExam = UserDefaults.standard.string(forKey: Constants.dateOfExamKey) else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(dateOfExam))
                
                return Disposables.create()
            }
    }
    
    // TODO: загружать с сервера, когда будет реализован запрос
    func loadDateOfExam() -> Single<String?> {
        Single<String?>
            .create { event in
                guard let dateOfExam = UserDefaults.standard.string(forKey: Constants.dateOfExamKey) else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(dateOfExam))
                
                return Disposables.create()
            }
            .do(onSuccess: { [weak self] dateOfExam in
                guard let self = self else {
                    return
                }
                
                self.store(dateOfExam: dateOfExam)
            })
            .delay(RxTimeInterval.seconds(2), scheduler: MainScheduler.asyncInstance)
    }
    
    func store(exam: Exam?) {
        guard let exam = exam, let data = try? JSONEncoder().encode(exam) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: Constants.examKey)
        
        ProfileMediator.shared.notifyAboutChanged(exam: exam)
    }
    
    func store(course: Course?) {
        guard let course = course, let data = try? JSONEncoder().encode(course) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: Constants.courseKey)
        
        ProfileMediator.shared.notifyAboutChanged(course: course)
    }
    
    func store(testMode: TestMode?) {
        guard let testMode = testMode, let data = try? JSONEncoder().encode(testMode) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: Constants.testModeKey)
        
        ProfileMediator.shared.notifyAboutChanged(testMode: testMode)
    }
    
    func cachedTestMode() -> Single<TestMode?> {
        Single<TestMode?>
            .create { event in
                guard
                    let data = UserDefaults.standard.data(forKey: Constants.testModeKey),
                    let mode = try? JSONDecoder().decode(TestMode.self, from: data)
                else {
                    event(.success(nil))
                    return Disposables.create()
                }

                event(.success(mode))
                
                return Disposables.create()
            }
    }
    
    func loadTestMode() -> Single<TestMode?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetTestModeRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetTestModeResponseMapper.map(from: $0) }
            .do(onSuccess: { [weak self] testMode in
                guard let self = self else {
                    return
                }
                
                self.store(testMode: testMode)
            })
    }
    
    func store(testMinutes: Int?) {
        guard let testMinutes = testMinutes else {
            return
        }

        UserDefaults.standard.set(testMinutes, forKey: Constants.testMinutesKey)
        
        ProfileMediator.shared.notifyAboutChanged(testMinutes: testMinutes)
    }
    
    func cachedTestMinutes() -> Single<Int?> {
        Single<Int?>
            .create { event in
                guard let testMinutes = UserDefaults.standard.value(forKey: Constants.testMinutesKey) as? Int else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(testMinutes))
                
                return Disposables.create()
            }
    }
    
    // TODO: загружать с сервера, когда будет реализован запрос
    func loadTestMinutes() -> Single<Int?> {
        Single<Int?>
            .create { event in
                guard let testMinutes = UserDefaults.standard.value(forKey: Constants.testMinutesKey) as? Int else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(testMinutes))
                
                return Disposables.create()
            }
            .do(onSuccess: { [weak self] testMinutes in
                guard let self = self else {
                    return
                }
                
                self.store(testMinutes: testMinutes)
            })
            .delay(RxTimeInterval.seconds(2), scheduler: MainScheduler.asyncInstance)
    }
}
