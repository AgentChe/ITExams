//
//  StatsView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 02.06.2022.
//

import UIKit

final class StatsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension StatsView {
    func initialize() {
        backgroundColor = Appearance.backgroundColor
    }
}

// MARK: Make constraints
private extension StatsView {
    func makeConstraints() {
        
    }
}

// MARK: Lazy initialization
private extension StatsView {
    
}
