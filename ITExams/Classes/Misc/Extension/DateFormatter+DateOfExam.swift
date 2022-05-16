//
//  DateFormatter+DateOfExam.swift
//  ITExams
//
//  Created by Андрей Чернышев on 16.05.2022.
//

import Foundation

extension DateFormatter {
    static func dateOfExamDisplayFormmater() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        formatter.locale = Locale.current
        return formatter
    }
}
