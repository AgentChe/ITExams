//
//  PaygatePlansView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.03.2022.
//

import UIKit

final class PaygatePlansView: UIView {
    lazy var backButton = makeBackButton()
    lazy var closeButton = makeCloseButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var cell1 = makeCell()
    lazy var cell2 = makeCell()
    lazy var cell3 = makeCell()
    lazy var lifetimeButton = makeProductButton()
    lazy var subscriptionButton = makeProductButton()
    lazy var continueButton = makeContinueButton()
    lazy var termsOfServiceButton = makeTermsOfServiceButton()
    lazy var restoreButton = makeRestoreButton()
    lazy var privacyPolicyButton = makePrivacyPolicyButton()
    lazy var preloader = makePreloader()
    
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
extension PaygatePlansView {
    func setup(questionsCount: Int) {
        cell1.setup(text: String(format: "Paygate.Plans.Cell1".localized, questionsCount))
        cell2.setup(text: "Paygate.Plans.Cell2".localized)
        cell3.setup(text: "Paygate.Plans.Cell3".localized)
    }
}

// MARK: Private
private extension PaygatePlansView {
    func initialize() {
        backgroundColor = Appearance.backgroundColor
    }
    
    @objc
    func productTapped(sender: UIButton) {
        guard let productButton = sender as? PaygateProductButton else {
            return
        }
        
        [lifetimeButton, subscriptionButton].forEach { $0.isChecked = false }
        
        productButton.isChecked = true
    }
}

// MARK: Make constraints
private extension PaygatePlansView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 24.scale),
            backButton.heightAnchor.constraint(equalToConstant: 24.scale),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 49.scale : 29.scale)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 49.scale : 29.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 94.scale : 74.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell1.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell1.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell2.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell2.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell2.topAnchor.constraint(equalTo: cell1.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell3.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell3.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell3.topAnchor.constraint(equalTo: cell2.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            lifetimeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            lifetimeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            lifetimeButton.heightAnchor.constraint(equalToConstant: 94.scale),
            lifetimeButton.topAnchor.constraint(equalTo: cell3.bottomAnchor, constant: 30.scale)
        ])
        
        NSLayoutConstraint.activate([
            subscriptionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            subscriptionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            subscriptionButton.heightAnchor.constraint(equalToConstant: 94.scale),
            subscriptionButton.topAnchor.constraint(equalTo: lifetimeButton.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 29.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -29.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 48.scale),
            continueButton.bottomAnchor.constraint(equalTo: termsOfServiceButton.topAnchor, constant: -20.scale)
        ])
        
        NSLayoutConstraint.activate([
            termsOfServiceButton.trailingAnchor.constraint(equalTo: restoreButton.leadingAnchor, constant: -16.scale),
            termsOfServiceButton.heightAnchor.constraint(equalToConstant: 17.scale),
            termsOfServiceButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -43.scale : -21.scale)
        ])
        
        NSLayoutConstraint.activate([
            restoreButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            restoreButton.heightAnchor.constraint(equalToConstant: 17.scale),
            restoreButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -43.scale : -21.scale)
        ])
        
        NSLayoutConstraint.activate([
            privacyPolicyButton.leadingAnchor.constraint(equalTo: restoreButton.trailingAnchor, constant: 16.scale),
            privacyPolicyButton.heightAnchor.constraint(equalToConstant: 17.scale),
            privacyPolicyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -43.scale : -21.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: subscriptionButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygatePlansView {
    func makeBackButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Paygate.Back"), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Paygate.Close"), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.bold(size: 24.scale))
            .lineHeight(28.8.scale)
            .letterSpacing(-0.44.scale)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Paygate.Plans.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCell() -> PaygatePlansCell {
        let view = PaygatePlansCell()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeProductButton() -> PaygateProductButton {
        let view = PaygateProductButton()
        view.backgroundColor = Appearance.whiteColor
        view.layer.borderWidth = 2.scale
        view.layer.cornerRadius = 10.scale
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 6.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(productTapped(sender:)), for: .touchUpInside)
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.whiteColor)
            .font(Fonts.Inter.semiBold(size: 17.scale))
            .letterSpacing(-0.44.scale)
        
        let view = UIButton()
        view.setAttributedTitle("Continue".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.mainColor
        view.layer.cornerRadius = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTermsOfServiceButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.greyColor.withAlphaComponent(0.6))
            .font(Fonts.Inter.regular(size: 12.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle("Paygate.Plans.TermsOfService".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeRestoreButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.greyColor.withAlphaComponent(0.6))
            .font(Fonts.Inter.regular(size: 12.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle("Paygate.Plans.Restore".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePrivacyPolicyButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.greyColor.withAlphaComponent(0.6))
            .font(Fonts.Inter.regular(size: 12.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle("Paygate.Plans.PrivacyPolicy".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .large
        view.color = Appearance.successColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
