//
//  DayOfWeek.swift
//  ITExams
//
//  Created by Андрей Чернышев on 16.05.2022.
//

enum DayOfWeek: String, Codable {
    case  su, mn, tu, we, th, fr, sa
}

// MARK: Public
extension DayOfWeek {
    var short: String {
        switch self {
        case .su:
            return "DayOfWeek.Short.Su".localized
        case .mn:
            return "DayOfWeek.Short.Mn".localized
        case .tu:
            return "DayOfWeek.Short.Tu".localized
        case .we:
            return "DayOfWeek.Short.We".localized
        case .th:
            return "DayOfWeek.Short.Th".localized
        case .fr:
            return "DayOfWeek.Short.Fr".localized
        case .sa:
            return "DayOfWeek.Short.Sa".localized
        }
    }
}
