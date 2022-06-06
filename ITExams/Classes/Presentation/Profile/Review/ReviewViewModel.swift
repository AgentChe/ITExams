//
//  ReviewViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 06.06.2022.
//

import RxSwift
import RxCocoa

final class ReviewViewModel {
    lazy var elements = makeElements()
    
    private lazy var currentCourse = makeCurrentCourse()
    
    private lazy var profileManager = ProfileManager()
    private lazy var questionManager = QuestionManager()
}

// MARK: Private
private extension ReviewViewModel {
    func makeElements() -> Driver<[ReviewTableElement]> {
        currentCourse
            .flatMapLatest { [weak self] course -> Driver<[Review]> in
                guard let self = self else {
                    return .never()
                }
                
                return self.questionManager
                    .obtainReview(for: course.id, mode: 1, offset: 0)
                    .asDriver(onErrorJustReturn: [])
            }
            .map { reviews -> [ReviewTableElement] in
                var result = [ReviewTableElement]()
                
                reviews.enumerated().forEach { index, review in
                    let question = ReviewTableQuestion(isCorrectly: review.isCorrectly,
                                                       question: review.question.question)
                    result.append(.question(question))
                    
                    if index != (reviews.count - 1) {
                        result.append(.separator)
                    }
                }
                
                return result
            }
    }
    
    func makeCurrentCourse() -> Driver<Course> {
        let initial = profileManager
            .obtainSelectedCourse(forceUpdate: false)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let updated = ProfileMediator.shared
            .changedCourse
            .asDriver(onErrorDriveWith: .never())
        
        return Driver.merge(initial, updated)
    }
}
