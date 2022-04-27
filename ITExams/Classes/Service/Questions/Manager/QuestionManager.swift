//
//  QuestionManager.swift
//  Nursing
//
//  Created by Vitaliy Zagorodnov on 08.02.2021.
//

import RxSwift

protocol QuestionManager: AnyObject {
    // MARK: API(Rx)
    func retrieve(courseId: Int, testId: Int?, activeSubscription: Bool, key: String) -> Single<Test?>
    func retrieveTenSet(courseId: Int, activeSubscription: Bool, key: String) -> Single<Test?>
    func retrieveFailedSet(courseId: Int, activeSubscription: Bool, key: String) -> Single<Test?>
    func retrieveQotd(courseId: Int, activeSubscription: Bool, key: String) -> Single<Test?>
    func retrieveRandomSet(courseId: Int, activeSubscription: Bool, key: String) -> Single<Test?>
    func retrieveOnboardingSet(key: String) -> Single<Test?>
    func sendAnswer(questionId: Int, userTestId: Int, answerIds: [Int]) -> Single<Bool?>
    func retrieveConfig(courseId: Int, key: String) -> Single<[TestConfig]>
}
