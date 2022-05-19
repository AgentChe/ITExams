//
//  ProfileMediatorDelegate.swift
//  ITExams
//
//  Created by Андрей Чернышев on 29.03.2022.
//

import Foundation

protocol ProfileMediatorDelegate: AnyObject {
    func prodileMediatorDidChanged(dateOfExam: Date)
    func prodileMediatorDidChanged(exam: Exam)
    func prodileMediatorDidChanged(course: Course)
    func prodileMediatorDidChanged(testMode: TestMode)
    func prodileMediatorDidChanged(testMinutes: Int)
    func prodileMediatorDidChanged(testDaysOfWeek: [DayOfWeek])
}
