//
//  OQuestionTableElement.swift
//  ITExams
//
//  Created by Андрей Чернышев on 07.06.2022.
//

import CoreGraphics

enum OQuestionTableElement {
    case offset(CGFloat)
    case question(String)
    case answer(OQuestionTableAnswer)
}

final class OQuestionTableAnswer {
    var isSelected: Bool
    let mark: String
    let answer: String
    
    init(isSelected: Bool,
         mark: String,
         answer: String) {
        self.isSelected = isSelected
        self.mark = mark
        self.answer = answer
    }
}
