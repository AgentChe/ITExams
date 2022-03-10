//
//  OnboardingCombineDate.swift
//  ITExams
//
//  Created by Андрей Чернышев on 10.03.2022.
//

import Foundation

struct OCombineData {
    let motivation: String
    let age: String
    let exam: String
    let course: String
    let examDate: String?
    let studyMode: String
}

final class OnboardingCombineData {
    private var motivation: String?
    private var age: String?
    private var exam: String?
    private var course: String?
    private var examDate: String?
    private var studyMode: String?
    
    func combineData() -> OCombineData? {
        guard
            let motivation = motivation,
            let age = age,
            let exam = exam,
            let course = course,
            let studyMode = studyMode
        else {
            return nil
        }
        
        return OCombineData(motivation: motivation,
                            age: age,
                            exam: exam,
                            course: course,
                            examDate: examDate,
                            studyMode: studyMode)
    }
}

// MARK: OMotivationViewDelegate
extension OnboardingCombineData: OMotivationViewDelegate {
    func motivationViewDidSelected(element: OMotivationElement) {
        self.motivation = element.title
    }
}

// MARK: OAgeViewDelegate
extension OnboardingCombineData: OAgeViewDelegate {
    func ageViewDidSelected(age: String) {
        self.age = String(format: "Onboarding.PlanView.Years".localized, age)
    }
}

// MARK: OExamsViewDelegate
extension OnboardingCombineData: OExamsViewDelegate {
    func examsDidSelected(element: OExamElement) {
        exam = element.title
    }
}

// MARK: OCourseViewDelegate
extension OnboardingCombineData: OCourseViewDelegate {
    func courseViewDidSelected(course: String) {
        self.course = course
    }
}

// MARK: OExamDateViewDelegate
extension OnboardingCombineData: OExamDateViewDelegate {
    func examDateDidSelected(date: Date?) {
        guard let date = date else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        formatter.locale = Locale.current
        
        self.examDate = formatter.string(from: date)
    }
}

// MARK: OStudyModeViewDelegate
extension OnboardingCombineData: OStudyModeViewDelegate {
    func studyModeViewDidSelected(element: OStudyModeElement) {
        self.studyMode = element.name
    }
}
