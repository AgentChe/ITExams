//
//  PracticeTableElement.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import CoreGraphics

enum PracticeTableElement {
    case offset(CGFloat)
    case examDate
    case title(String)
    case dailyQuestion
    case tests
    case unlockPremium(Int)
}
