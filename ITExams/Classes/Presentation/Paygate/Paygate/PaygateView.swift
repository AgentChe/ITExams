//
//  PaygateView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.03.2022.
//

import UIKit

final class PaygateView: UIView {
    lazy var closeButton = makeCloseButton()
    lazy var restoreButton = makeRestoreButton()
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var cell1 = makeCell()
    lazy var cell2 = makeCell()
    lazy var cell3 = makeCell()
    lazy var lifetimeButton = makeProductButton()
    lazy var subscriptionButton = makeProductButton()
    lazy var infoIconView = makeInfoIconView()
    lazy var infoLabel = makeInfoLabel()
    lazy var continueButton = makeContinueButton()
    lazy var termsOfServiceButton = makeTermsOfServiceButton()
    lazy var andLabel = makeAndLabel()
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
extension PaygateView {
    func setup(questionsCount: Int) {
        cell1.setup(text: "Paygate.Cell1".localized)
        cell2.setup(text: String(format: "Paygate.Cell2".localized, questionsCount))
        cell3.setup(text: "Paygate.Cell3".localized)
    }
}

// MARK: Private
private extension PaygateView {
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
private extension PaygateView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 49.scale : 29.scale)
        ])
        
        NSLayoutConstraint.activate([
            restoreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            restoreButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 191.scale),
            imageView.heightAnchor.constraint(equalToConstant: 142.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 88.scale : 45.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell1.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell1.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 16.scale : 12.scale),
            cell1.heightAnchor.constraint(equalToConstant: 23.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell2.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell2.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell2.topAnchor.constraint(equalTo: cell1.bottomAnchor, constant: 7.scale),
            cell2.heightAnchor.constraint(equalToConstant: 23.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell3.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell3.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell3.topAnchor.constraint(equalTo: cell2.bottomAnchor, constant: 7.scale),
            cell3.heightAnchor.constraint(equalToConstant: 23.scale)
        ])
        
        NSLayoutConstraint.activate([
            lifetimeButton.widthAnchor.constraint(equalToConstant: 161.scale),
            lifetimeButton.heightAnchor.constraint(equalToConstant: 185.scale),
            lifetimeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            lifetimeButton.topAnchor.constraint(equalTo: cell3.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 24.scale : 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            subscriptionButton.widthAnchor.constraint(equalToConstant: 161.scale),
            subscriptionButton.heightAnchor.constraint(equalToConstant: 185.scale),
            subscriptionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            subscriptionButton.topAnchor.constraint(equalTo: cell3.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 24.scale : 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            infoIconView.widthAnchor.constraint(equalToConstant: 20.scale),
            infoIconView.heightAnchor.constraint(equalToConstant: 20.scale),
            infoIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 52.scale),
            infoIconView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: ScreenSize.isIphoneXFamily ? -12.scale : -6.scale)
        ])
        
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: infoIconView.trailingAnchor, constant: 5.scale),
            infoLabel.centerYAnchor.constraint(equalTo: infoIconView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 29.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -29.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 48.scale),
            continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -100.scale : -40.scale)
        ])
        
        NSLayoutConstraint.activate([
            termsOfServiceButton.trailingAnchor.constraint(equalTo: andLabel.leadingAnchor),
            termsOfServiceButton.heightAnchor.constraint(equalToConstant: 20.scale),
            termsOfServiceButton.centerYAnchor.constraint(equalTo: andLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            andLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            andLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -48.scale : -12.scale)
        ])
        
        NSLayoutConstraint.activate([
            privacyPolicyButton.leadingAnchor.constraint(equalTo: andLabel.trailingAnchor),
            privacyPolicyButton.heightAnchor.constraint(equalToConstant: 20.scale),
            privacyPolicyButton.centerYAnchor.constraint(equalTo: andLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateView {
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Paygate.Close"), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeRestoreButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.greyColor)
            .font(Fonts.Inter.regular(size: 14.scale))
            .letterSpacing(-0.14.scale)
        
        let view = TapAreaButton()
        view.setAttributedTitle("Paygate.RestorePurchases".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Paygate.Image")
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
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Paygate.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCell() -> PaygateInfoCell {
        let view = PaygateInfoCell()
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(productTapped(sender:)), for: .touchUpInside)
        addSubview(view)
        return view
    }
    
    func makeInfoIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Paygate.Lock")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeInfoLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.greyColor)
            .font(Fonts.Inter.regular(size: 14.scale))
            .lineHeight(19.6.scale)
            .letterSpacing(-0.14.scale)
        
        let view = UILabel()
        view.attributedText = "Paygate.Info".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
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
            .textColor(Appearance.greyColor)
            .font(Fonts.Inter.regular(size: 14.scale))
            .letterSpacing(-0.14.scale)
            .underlineColor(Appearance.greyColor)
            .underlineStyle(.single)
        
        let view = TapAreaButton()
        view.setAttributedTitle("Paygate.TermsOfUse".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeAndLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.greyColor)
            .font(Fonts.Inter.regular(size: 14.scale))
            .letterSpacing(-0.14.scale)
        
        let view = UILabel()
        view.attributedText = "Paygate.And".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePrivacyPolicyButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.greyColor)
            .font(Fonts.Inter.regular(size: 14.scale))
            .letterSpacing(-0.14.scale)
            .underlineColor(Appearance.greyColor)
            .underlineStyle(.single)
        
        let view = TapAreaButton()
        view.setAttributedTitle("Paygate.PrivacyPolicy".localized.attributed(with: attrs), for: .normal)
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
