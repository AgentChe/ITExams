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
             examDate: Date?,
             testMode: TestMode?,
             testMinutes: Int?,
             testDaysOfWeek: [DayOfWeek]?,
             exam: Exam?,
             course: Course?) -> Single<Void>
    func obtainProfile(forceUpdate: Bool) -> Single<Profile?>
    func obtainReferenceDateOfExam() -> Single<Date?>
    func obtainDateOfExam(forceUpdate: Bool) -> Single<Date?>
    func obtainExams() -> Single<[Exam]>
    func obtainSelectedExam() -> Single<Exam?>
    func obtainSelectedCourse(forceUpdate: Bool) -> Single<Course?>
    func obtainTestMode(forceUpdate: Bool) -> Single<TestMode?>
    func obtainTestMinutes(forceUpdate: Bool) -> Single<Int?>
    func obtainTestDaysOfWeek() -> Single<[DayOfWeek]?>
    func syncTokens(oldToken: String, newToken: String) -> Single<Void>
    func login(userToken: String) -> Single<Void>
}

final class ProfileManager: ProfileManagerProtocol {
    enum Constants {
        static let referenceDateOfExamKey = "profile_manager_reference_date_of_exam_key"
        static let dateOfExamKey = "profile_manager_date_of_exam_key"
        static let examKey = "profile_manager_exam_key"
        static let courseKey = "profile_manager_course_key"
        static let testModeKey = "profile_manager_test_mode_key"
        static let testMinutesKey = "profile_manager_test_minutes_key"
        static let testDaysOfWeekKey = "profile_manager_days_of_week_key"
    }
    
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Study
extension ProfileManager {
    func set(motivation: Int? = nil,
             examDate: Date? = nil,
             testMode: TestMode? = nil,
             testMinutes: Int? = nil,
             testDaysOfWeek: [DayOfWeek]? = nil,
             exam: Exam? = nil,
             course: Course? = nil) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SetRequest(userToken: userToken,
                                 level: motivation,
                                 testMode: testMode?.code(),
                                 examDate: examDateStringFormatted(examDate),
                                 testMinutes: testMinutes,
                                 courseId: course?.id)
        
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
                self.store(testDaysOfWeek: testDaysOfWeek)
                self.store(exam: exam)
                self.store(course: course)
            })
    }
    
    func obtainProfile(forceUpdate: Bool) -> Single<Profile?> {
        forceUpdate ? loadProfile() : cachedProfile()
    }
    
    func obtainReferenceDateOfExam() -> Single<Date?> {
        Single<Date?>
            .create { event in
                guard let date = UserDefaults.standard.value(forKey: Constants.referenceDateOfExamKey) as? Date else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(date))
                
                return Disposables.create()
            }
    }
    
    func obtainDateOfExam(forceUpdate: Bool) -> Single<Date?> {
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
                         domain: GlobalDefinitions.cisspDomainUrl),
                    Exam(code: "ACMA",
                         title: "Onboarding.Exams.Exam4.Name".localized,
                         subTitle: "Onboarding.Exams.Exam4.Text".localized,
                         api: GlobalDefinitions.acmaApiKey,
                         domain: GlobalDefinitions.acmaDomainUrl)
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
    
    func obtainSelectedCourse(forceUpdate: Bool) -> Single<Course?> {
        forceUpdate ? loadSelectedCourse() : cachedSelectedCourse()
    }
    
    func obtainTestMode(forceUpdate: Bool) -> Single<TestMode?> {
        forceUpdate ? loadTestMode() : cachedTestMode()
    }
    
    func obtainTestMinutes(forceUpdate: Bool) -> Single<Int?> {
        forceUpdate ? loadTestMinutes() : cachedTestMinutes()
    }
    
    func obtainTestDaysOfWeek() -> Single<[DayOfWeek]?> {
        Single<[DayOfWeek]?>
            .create { event in
                guard
                    let data = UserDefaults.standard.data(forKey: Constants.testDaysOfWeekKey),
                    let testDaysOfWeek = try? JSONDecoder().decode([DayOfWeek].self, from: data)
                else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(testDaysOfWeek))
                
                return Disposables.create()
            }
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
    func cachedProfile() -> Single<Profile?> {
        let testMode = cachedTestMode()
        let testMinutes = cachedTestMinutes()
        let examDate = cachedDateOfExam()
        let selectedCourse = cachedSelectedCourse()
        
        return Single
            .zip(
                testMode,
                testMinutes,
                examDate,
                selectedCourse
            ) { testMode, testMinutes, examDate, selectedCourse -> Profile in
                Profile(testMode: testMode,
                        testMinutes: testMinutes,
                        examDate: examDate,
                        selectedCourse: selectedCourse)
            }
    }
    
    func loadProfile() -> Single<Profile?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetProfileRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetProfileResponseMapper.map(from: $0) }
            .do(onSuccess: { [weak self] profile in
                guard let self = self, let profile = profile else {
                    return
                }
                
                self.store(testMode: profile.testMode)
                self.store(testMinutes: profile.testMinutes)
                self.store(dateOfExam: profile.examDate)
                self.store(course: profile.selectedCourse)
            })
    }
    
    func store(dateOfExam: Date?) {
        guard let dateOfExam = dateOfExam else {
            return
        }
        
        UserDefaults.standard.set(dateOfExam, forKey: Constants.dateOfExamKey)
        UserDefaults.standard.set(Date(), forKey: Constants.referenceDateOfExamKey)
        
        ProfileMediator.shared.notifyAboutChanged(dateOfExam: dateOfExam)
    }
    
    func cachedDateOfExam() -> Single<Date?> {
        Single<Date?>
            .create { event in
                guard let dateOfExam = UserDefaults.standard.value(forKey: Constants.dateOfExamKey) as? Date else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(dateOfExam))
                
                return Disposables.create()
            }
    }
    
    func loadDateOfExam() -> Single<Date?> {
        loadProfile()
            .map { $0?.examDate }
            .do(onSuccess: { [weak self] dateOfExam in
                guard let self = self, let dateOfExam = dateOfExam else {
                    return
                }
                
                self.store(dateOfExam: dateOfExam)
            })
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
    
    func cachedSelectedCourse() -> Single<Course?> {
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
    
    func loadSelectedCourse() -> Single<Course?> {
        loadProfile()
            .map { $0?.selectedCourse }
            .do(onSuccess: { [weak self] course in
                guard let self = self, let course = course else {
                    return
                }
                
                self.store(course: course)
            })
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
        loadProfile()
            .map { $0?.testMode }
            .do(onSuccess: { [weak self] testMode in
                guard let self = self, let testMode = testMode else {
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
    
    func loadTestMinutes() -> Single<Int?> {
        loadProfile()
            .map { $0?.testMinutes }
            .do(onSuccess: { [weak self] testMinutes in
                guard let self = self, let testMinutes = testMinutes else {
                    return
                }
                
                self.store(testMinutes: testMinutes)
            })
    }
    
    func store(testDaysOfWeek: [DayOfWeek]?) {
        guard
            let testDaysOfWeek = testDaysOfWeek,
            let data = try? JSONEncoder().encode(testDaysOfWeek)
        else {
            return
        }

        UserDefaults.standard.set(data, forKey: Constants.testDaysOfWeekKey)
        
        ProfileMediator.shared.notifyAboutChanged(testDaysOfWeek: testDaysOfWeek)
    }
    
    func examDateStringFormatted(_ date: Date?) -> String? {
        guard let date = date else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale.current
        
        return formatter.string(from: date)
    }
}
