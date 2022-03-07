//
//  OExamsTableElement.swift
//  ITExams
//
//  Created by Андрей Чернышев on 04.03.2022.
//

import Foundation

final class OExamsTableElement {
    let id: String = UUID().uuidString
    let title: String
    let subTitle: String
    var isSelected: Bool
    
    init(title: String,
         subTitle: String,
         isSelected: Bool = false) {
        self.title = title
        self.subTitle = subTitle
        self.isSelected = isSelected
    }
}
