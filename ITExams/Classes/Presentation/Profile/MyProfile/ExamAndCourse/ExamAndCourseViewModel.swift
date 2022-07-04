//
//  ExamAndCourseViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 04.07.2022.
//

import RxSwift
import RxCocoa

final class ExamAndCourseViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var selectExam = PublishRelay<Exam>()
    lazy var selectCourse = PublishRelay<Course>()
    lazy var backTapped = PublishRelay<Void>()
    
    lazy var saved = makeSaved()
    lazy var elements = makeElements()
    lazy var activity = RxActivityIndicator()
    
    private lazy var save = makeSave()
    private lazy var coursesElements = makeCoursesElements()
    private lazy var examsElements = makeExamsElements()
    private lazy var initialCourse = makeInitialCourse()
    private lazy var courses = makeCourses()
    private lazy var initialExam = makeInitialExam()
    private lazy var exams = makeExams()
    
    private lazy var profileManager = ProfileManager()
    private lazy var coursesManager = CoursesManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension ExamAndCourseViewModel {
    func makeSave() -> Driver<ExamEnvironment> {
        selectCourse
            .withLatestFrom(selectExam) { ExamEnvironment(exam: $1, course: $0) }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeSaved() -> Driver<Void> {
        save
            .flatMapLatest { [weak self] save -> Driver<Void> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Void> {
                    self.profileManager
                        .obtainExams()
                        .flatMap { [weak self] exams -> Single<Void> in
                            guard let self = self else {
                                return .never()
                            }
                            
                            let requests = exams
                                .map { environment -> Single<Void> in
                                    self.profileManager.set(domain: environment.domain,
                                                            apiKey: environment.api,
                                                            exam: save.exam,
                                                            course: save.course
                                    )
                                }
                            
                            return Single
                                .zip(requests)
                                .mapToVoid()
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
    
    func makeElements() -> Driver<[EACTableElement]> {
        Driver
            .merge(examsElements, coursesElements)
    }
    
    func makeCoursesElements() -> Driver<[EACTableElement]> {
        Driver
            .combineLatest(initialCourse, courses) { initialCourse, courses -> [EACTableElement] in
                courses
                    .map { course -> EACTableElement in
                        EACCourseElement(course: course, isSelected: course.id == initialCourse?.id)
                    }
            }
    }
    
    func makeExamsElements() -> Driver<[EACTableElement]> {
        let initial = Driver
            .combineLatest(initialExam, exams) { initialExam, exams -> [EACTableElement] in
                exams
                    .map { exam -> EACTableElement in
                        EACExamElement(exam: exam, isSelected: exam.code == initialExam?.code)
                    }
            }
        
        return initial
            .flatMapFirst { [weak self] elements -> Driver<[EACTableElement]> in
                guard let self = self else {
                    return .never()
                }
                
                return self.backTapped
                    .map { elements }
                    .startWith(elements)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeInitialCourse() -> Driver<Course?> {
        profileManager
            .obtainExamEnvironment()
            .map { $0?.course }
            .asDriver(onErrorJustReturn: nil)
    }
    
    func makeCourses() -> Driver<[Course]> {
        selectExam
            .flatMapLatest { [weak self] exam -> Observable<[Course]> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<[Course]> {
                    self.coursesManager
                        .obtainCourses(domain: exam.domain, apiKey: exam.api)
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(self.activity)
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeInitialExam() -> Driver<Exam?> {
        profileManager
            .obtainExamEnvironment()
            .map { $0?.exam }
            .asDriver(onErrorJustReturn: nil)
    }
    
    func makeExams() -> Driver<[Exam]> {
        profileManager
            .obtainExams()
            .asDriver(onErrorJustReturn: [])
    }
}
