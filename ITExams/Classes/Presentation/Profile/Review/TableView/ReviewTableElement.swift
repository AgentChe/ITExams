//
//  ReviewTableElement.swift
//  ITExams
//
//  Created by Андрей Чернышев on 06.06.2022.
//

enum ReviewTableElement {
    case question(ReviewTableQuestion)
    case separator
}

struct ReviewTableQuestion {
    let isCorrectly: Bool
    let question: String
}
