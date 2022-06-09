//
//  PracticeTableTitleCell.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import UIKit

final class PracticeTableTitleCell: UITableViewCell {
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
extension PracticeTableTitleCell {
    func setup(element: String) {
        
    }
}

// MARK: Private
private extension PracticeTableTitleCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension PracticeTableTitleCell {
    func makeConstraints() {
        
    }
}

// MARK: Lazy initialization
private extension PracticeTableTitleCell {
    
}
