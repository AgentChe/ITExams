//
//  ExamAndCourseTableElement.swift
//  ITExams
//
//  Created by Андрей Чернышев on 04.07.2022.
//

protocol EACTableElement: AnyObject {
    var title: String { get set }
    var subTitle: String { get set }
    var isSelected: Bool { get set }
}

final class EACExamElement: EACTableElement {
    let element: Exam
    var title: String
    var subTitle: String
    var isSelected: Bool
    
    init(exam: Exam,
         isSelected: Bool) {
        self.element = exam
        self.title = exam.title
        self.subTitle = exam.subTitle
        self.isSelected = isSelected
    }
}

final class EACCourseElement: EACTableElement {
    let element: Course
    var title: String
    var subTitle: String
    var isSelected: Bool
    
    init(course: Course,
         isSelected: Bool) {
        self.element = course
        self.title = course.name
        self.subTitle = course.subTitle
        self.isSelected = isSelected
    }
}
