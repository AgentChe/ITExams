//
//  PracticeTableExamDateCell.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import UIKit

final class PracticeTableExamDateCell: UITableViewCell {
    weak var mainDelegate: PracticeTableViewDelegate?
    
    lazy var titleLabel = makeTitleLabel()
    lazy var changeExamDateButton = makeChangeExamDateButton()
    
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
extension PracticeTableExamDateCell {
    func setup(element: Date?) {
        
    }
}

// MARK: Private
private extension PracticeTableExamDateCell {
    func initialize() {
        backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor.white
        
        selectionStyle = .none
    }
    
    @objc
    func tappedChangeDate() {
        mainDelegate?.practiceTableDidTappedChangeExamDate()
    }
}

// MARK: Make constraints
private extension PracticeTableExamDateCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 58.scale)
        ])
        
        NSLayoutConstraint.activate([
            changeExamDateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.scale),
            changeExamDateButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            changeExamDateButton.widthAnchor.constraint(equalToConstant: 109.scale),
            changeExamDateButton.heightAnchor.constraint(equalToConstant: 40.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PracticeTableExamDateCell {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.bold(size: 24.scale))
            .lineHeight(28.8.scale)
            .letterSpacing(-0.44.scale)
        
        let view = UILabel()
        view.attributedText = "Practice.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeChangeExamDateButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.regular(size: 14.scale))
            .letterSpacing(-0.14.scale)
        
        let view = UIButton()
        view.setAttributedTitle("Practice.ChangeExamDate".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.buttonBackgroundColor
        view.layer.cornerRadius = 8.scale
        view.addTarget(self, action: #selector(tappedChangeDate), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
