//
//  TestStatsFilterButton.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import UIKit

final class TestStatsFilterButton: UIButton {
    var isChecked = false {
        didSet {
            update()
        }
    }
    
    private let text: String
    
    init(text: String) {
        self.text = text
        
        super.init(frame: .zero)
        
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension TestStatsFilterButton {
    func update() {
        let attrs = TextAttributes()
            .textColor(isChecked ? Appearance.whiteColor : Appearance.blackColor)
            .font(Fonts.Inter.regular(size: 15.scale))
            .letterSpacing(-0.14.scale)
        setAttributedTitle(text.attributed(with: attrs), for: .normal)
        
        backgroundColor = isChecked ? Appearance.mainColor : Appearance.buttonBackgroundColor
    }
}
