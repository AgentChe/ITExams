//
//  OnboardingCombineDate.swift
//  ITExams
//
//  Created by Андрей Чернышев on 10.03.2022.
//

import Foundation

struct OCombineData {
    let motivation: OMotivationElement
    let age: String
    let exam: Exam
    let course: Course
    let examDate: String?
    let studyMode: OStudyModeElement
    let testMinutes: Int
}

final class OnboardingCombineData {
    private var motivation: OMotivationElement?
    private var age: String?
    private var exam: Exam?
    private var course: Course?
    private var examDate: String?
    private var studyMode: OStudyModeElement?
    private var testMinutes: Int?
    
    func combineData() -> OCombineData? {
        guard
            let motivation = motivation,
            let age = age,
            let exam = exam,
            let course = course,
            let studyMode = studyMode,
            let testMinutes = testMinutes
        else {
            return nil
        }
        
        return OCombineData(motivation: motivation,
                            age: age,
                            exam: exam,
                            course: course,
                            examDate: examDate,
                            studyMode: studyMode,
                            testMinutes: testMinutes)
    }
}

// MARK: OMotivationViewDelegate
extension OnboardingCombineData: OMotivationViewDelegate {
    func motivationViewDidSelected(element: OMotivationElement) {
        self.motivation = element
    }
}

// MARK: OAgeViewDelegate
extension OnboardingCombineData: OAgeViewDelegate {
    func ageViewDidSelected(age: String) {
        self.age = String(format: "Onboarding.CreatingPlanView.Years".localized, age)
    }
}

// MARK: OExamsViewDelegate
extension OnboardingCombineData: OExamsViewDelegate {
    func examsDidSelected(element: Exam) {
        exam = element
    }
}

// MARK: OCourseViewDelegate
extension OnboardingCombineData: OCourseViewDelegate {
    func courseViewDidSelected(course: Course) {
        self.course = course
    }
}

// MARK: OExamDateViewDelegate
extension OnboardingCombineData: OExamDateViewDelegate {
    func examDateDidSelected(date: Date?) {
        guard let date = date else {
            return
        }
        
        let formatter = DateFormatter.dateOfExamDisplayFormmater()
        
        self.examDate = formatter.string(from: date)
    }
}

// MARK: OStudyModeViewDelegate
extension OnboardingCombineData: OStudyModeViewDelegate {
    func studyModeViewDidSelected(element: OStudyModeElement) {
        self.studyMode = element
    }
}

// MARK: ODailyGoalViewDelegate
extension OnboardingCombineData: ODailyGoalViewDelegate {
    func dailyGoalDidSelected(testMinutes: Int) {
        self.testMinutes = testMinutes
    }
}
