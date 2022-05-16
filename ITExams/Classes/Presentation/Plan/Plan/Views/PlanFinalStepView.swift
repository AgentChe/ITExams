//
//  PlanFinalStepView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 16.05.2022.
//

import UIKit

final class PlanFinalStepView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var button = makeButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
extension PlanFinalStepView {
    func setup(locked: Bool) {
        // TODO: блокировать в соответствии с дизайном
    }
}

// MARK: Make constraints
private extension PlanFinalStepView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            button.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 24.scale),
            button.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PlanFinalStepView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.regular(size: 15.scale))
            .lineHeight(22.5.scale)
            .letterSpacing(-0.14.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Plan.FinalStep.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.greyColor)
            .font(Fonts.Inter.regular(size: 15.scale))
            .lineHeight(22.5.scale)
            .letterSpacing(-0.14.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Plan.FinalStep.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.whiteColor)
            .font(Fonts.Inter.semiBold(size: 17.scale))
            .letterSpacing(-0.44.scale)
        
        let view = UIButton()
        view.setAttributedTitle("Plan.FinalStep.Button".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.mainColor
        view.layer.cornerRadius = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

