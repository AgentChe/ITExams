//
//  QuestionsCountCollectionCell.swift
//  ITExams
//
//  Created by Андрей Чернышев on 15.06.2022.
//

import UIKit

final class QuestionsCountCollectionCell: UICollectionViewCell {
    lazy var container = makeContainer()
    lazy var label = makeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension QuestionsCountCollectionCell {
    func setup(element: QuestionsCountCollectionElement) {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.bold(size: 24.scale))
            .lineHeight(28.8.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        label.attributedText = String(element.count).attributed(with: attrs)
        
        label.alpha = element.isSelected ? 1 : 0.2
        
        container.layer.borderWidth = element.isSelected ? 2.scale : 0
        container.layer.borderColor = element.isSelected ? Appearance.mainColor.cgColor : UIColor.clear.cgColor
    }
}

// MARK: Private
private extension QuestionsCountCollectionCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView = selectedView
    }
}

// MARK: Make constraints
private extension QuestionsCountCollectionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension QuestionsCountCollectionCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
