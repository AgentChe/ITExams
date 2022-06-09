//
//  PracticeTableDailyQuestionCell.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import UIKit

final class PracticeTableDailyQuestionCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension PracticeTableDailyQuestionCell {
    func setup(element: String) {
        
    }
}

// MARK: Private
private extension PracticeTableDailyQuestionCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension PracticeTableDailyQuestionCell {
    func makeConstraints() {
        
    }
}

// MARK: Lazy initialization
private extension PracticeTableDailyQuestionCell {
    
}
