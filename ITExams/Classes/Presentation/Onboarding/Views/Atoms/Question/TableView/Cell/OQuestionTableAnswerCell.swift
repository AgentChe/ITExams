//
//  OQuestionTableAnswerCell.swift
//  ITExams
//
//  Created by Андрей Чернышев on 07.06.2022.
//

import UIKit

final class OQuestionTableAnswerCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var markLabel = makeLabel()
    lazy var answerLabel = makeLabel()
    
    private lazy var answerLabelTopConstraint = NSLayoutConstraint()
    private lazy var answerLabelBottomConstraint = NSLayoutConstraint()
    
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
extension OQuestionTableAnswerCell {
    func setup(element: OQuestionTableAnswer) {
        markLabel.attributedText = element.mark
            .attributed(with: TextAttributes()
                            .textColor(element.isSelected ? Appearance.mainColor : Appearance.greyColor)
                            .font(Fonts.Inter.regular(size: 15.scale))
                            .lineHeight(22.5.scale)
                            .letterSpacing(-0.14.scale))
        
        answerLabel.attributedText = element.answer
            .attributed(with: TextAttributes()
                            .textColor(Appearance.blackColor)
                            .font(Fonts.Inter.regular(size: 15.scale))
                            .lineHeight(22.5.scale)
                            .letterSpacing(-0.14.scale))
        
        container.layer.borderWidth = element.isSelected ? 1.scale : 0
        container.layer.borderColor = element.isSelected ? Appearance.mainColor.cgColor : UIColor.clear.cgColor
        container.backgroundColor = element.isSelected ? Appearance.mainColor.withAlphaComponent(0.1) : Appearance.whiteColor
        
        NSLayoutConstraint.deactivate([
            answerLabelTopConstraint, answerLabelBottomConstraint
        ])
        answerLabelTopConstraint.constant = element.isSelected ? 19.scale : 15.scale
        answerLabelBottomConstraint.constant = element.isSelected ? -19.scale : -15.scale
        NSLayoutConstraint.activate([
            answerLabelTopConstraint, answerLabelBottomConstraint
        ])
        
        layoutIfNeeded()
    }
}

// MARK: Private
private extension OQuestionTableAnswerCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension OQuestionTableAnswerCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            markLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15.scale),
            markLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        answerLabelTopConstraint = answerLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 15.scale)
        answerLabelBottomConstraint = answerLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -15.scale)
        NSLayoutConstraint.activate([
            answerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 47.scale),
            answerLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale),
            answerLabelTopConstraint,
            answerLabelBottomConstraint
        ])
    }
}

// MARK: Lazy initialization
private extension OQuestionTableAnswerCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 6.scale
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
