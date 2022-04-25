//
//  CoursesView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 25.04.2022.
//

import UIKit

final class CoursesView: UIView {
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
private extension CoursesView {
    func initialize() {
        backgroundColor = Appearance.backgroundColor
    }
}

// MARK: Make constraints
private extension CoursesView {
    func makeConstraints() {
        
    }
}

// MARK: Lazy initialization
private extension CoursesView {
    
}
