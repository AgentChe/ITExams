//
//  PaygateTrialView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.03.2022.
//

import UIKit

final class PaygateTrialView: UIView {
    lazy var closeButton = makeCloseButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var cell1TitleLabel = makeCell1TitleLabel()
    lazy var cell1SubTitleLabel = makeCellSubTitleLabel()
    lazy var cell1ImageView = makeImageView(image: "Paygate.Install")
    lazy var cell1LineView = makeLineView(color: Appearance.successColor)
    lazy var cell2TitleLabel = makeCellTitleLabel(text: "Paygate.FreeTrial.Cell2.Title".localized)
    lazy var cell2SubTitleLabel = makeCellSubTitleLabel()
    lazy var cell2ImageView = makeImageView(image: "Paygate.Today")
    lazy var cell2ImageBackView = makeCellImageBackView()
    lazy var cell2Line1View = makeLineView(color: Appearance.successColor)
    lazy var cell2Line2View = makeLineView(color: Appearance.successColor.withAlphaComponent(0.1))
    lazy var cell3TitleLabel = makeCellTitleLabel(text: "Paygate.FreeTrial.Cell3.Title".localized)
    lazy var cell3SubTitleLabel = makeCellSubTitleLabel()
    lazy var cell3ImageView = makeImageView(image: "Paygate.Day5")
    lazy var cell3LineView = makeLineView(color: Appearance.successColor.withAlphaComponent(0.1))
    lazy var cell4TitleLabel = makeCellTitleLabel(text: "Paygate.FreeTrial.Cell4.Title".localized)
    lazy var cell4SubTitleLabel = makeCellSubTitleLabel()
    lazy var cell4ImageView = makeImageView(image: "Paygate.Day7")
    lazy var priceLabel = makePriceLabel()
    lazy var trialButton = makeTrialButton()
    lazy var plansButton = makePlansButton()
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
extension PaygateTrialView {
    func setup(questionsCount: Int) {
        let attrs = TextAttributes()
            .textColor(Appearance.greyColor)
            .font(Fonts.Inter.regular(size: 15.scale))
            .lineHeight(22.5.scale)
            .letterSpacing(-0.14.scale)
        cell1SubTitleLabel.attributedText = "Paygate.FreeTrial.Cell1.SubTitle".localized.attributed(with: attrs)
        cell2SubTitleLabel.attributedText = String(format: "Paygate.FreeTrial.Cell2.SubTitle".localized, questionsCount).attributed(with: attrs)
        cell3SubTitleLabel.attributedText = "Paygate.FreeTrial.Cell3.SubTitle".localized.attributed(with: attrs)
        cell4SubTitleLabel.attributedText = "Paygate.FreeTrial.Cell4.SubTitle".localized.attributed(with: attrs)
    }
    
    func setup(price: PaygatePrice) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = price.price.priceLocale

        let priceDiv: Double = price.price.priceValue / 53
        let priceDivLocalized: String
        if priceDiv < 100 {
            formatter.maximumFractionDigits = 1
            priceDivLocalized = formatter.string(from: NSNumber(value: (priceDiv * 10).rounded() / 10)) ?? ""
        } else {
            formatter.maximumFractionDigits = 0
            priceDivLocalized = formatter.string(from: NSNumber(value: round(priceDiv))) ?? ""
        }

        formatter.maximumFractionDigits = price.price.priceValue.truncatingRemainder(dividingBy: 1) > 0 ? 2 : 0
        let priceLocalized = formatter.string(from: NSNumber(value: price.price.priceValue)) ?? ""
        
        let priceResult = priceLocalized.removingWhitespaces()
        let pricePeriodResult = priceDivLocalized.removingWhitespaces()
        
        priceLabel.attributedText = String(format: "Paygate.FreeTrial.Price".localized, priceResult, pricePeriodResult)
            .attributed(with: TextAttributes()
                            .textColor(Appearance.blackColor)
                            .font(Fonts.Inter.regular(size: 15.scale))
                            .lineHeight(19.scale)
                            .letterSpacing(-0.44.scale)
                            .textAlignment(.center))
    }
}

// MARK: Private
private extension PaygateTrialView {
    func initialize() {
        backgroundColor = Appearance.backgroundColor
    }
}

// MARK: Make constraints
private extension PaygateTrialView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 49.scale : 29.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 94.scale : 44.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell1TitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 89.scale),
            cell1TitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            cell1TitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 23.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell1SubTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 89.scale),
            cell1SubTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            cell1SubTitleLabel.topAnchor.constraint(equalTo: cell1TitleLabel.bottomAnchor, constant: 7.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell1ImageView.widthAnchor.constraint(equalToConstant: 40.scale),
            cell1ImageView.heightAnchor.constraint(equalToConstant: 40.scale),
            cell1ImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            cell1ImageView.topAnchor.constraint(equalTo: cell1TitleLabel.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cell1LineView.widthAnchor.constraint(equalToConstant: 8.scale),
            cell1LineView.heightAnchor.constraint(equalToConstant: 52.scale),
            cell1LineView.centerXAnchor.constraint(equalTo: cell1ImageView.centerXAnchor),
            cell1LineView.topAnchor.constraint(equalTo: cell1ImageView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cell2TitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 89.scale),
            cell2TitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            cell2TitleLabel.topAnchor.constraint(equalTo: cell1SubTitleLabel.bottomAnchor, constant: 15.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell2SubTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 89.scale),
            cell2SubTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            cell2SubTitleLabel.topAnchor.constraint(equalTo: cell2TitleLabel.bottomAnchor, constant: 7.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell2ImageView.widthAnchor.constraint(equalToConstant: 40.scale),
            cell2ImageView.heightAnchor.constraint(equalToConstant: 40.scale),
            cell2ImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            cell2ImageView.topAnchor.constraint(equalTo: cell1LineView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cell2ImageBackView.widthAnchor.constraint(equalToConstant: 56.scale),
            cell2ImageBackView.heightAnchor.constraint(equalToConstant: 56.scale),
            cell2ImageBackView.centerXAnchor.constraint(equalTo: cell2ImageView.centerXAnchor),
            cell2ImageBackView.centerYAnchor.constraint(equalTo: cell2ImageView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cell2Line1View.widthAnchor.constraint(equalToConstant: 8.scale),
            cell2Line1View.heightAnchor.constraint(equalToConstant: 26.scale),
            cell2Line1View.centerXAnchor.constraint(equalTo: cell2ImageView.centerXAnchor),
            cell2Line1View.topAnchor.constraint(equalTo: cell2ImageView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cell2Line2View.widthAnchor.constraint(equalToConstant: 8.scale),
            cell2Line2View.heightAnchor.constraint(equalToConstant: 26.scale),
            cell2Line2View.centerXAnchor.constraint(equalTo: cell2ImageView.centerXAnchor),
            cell2Line2View.topAnchor.constraint(equalTo: cell2Line1View.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cell3TitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 89.scale),
            cell3TitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            cell3TitleLabel.topAnchor.constraint(equalTo: cell2SubTitleLabel.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell3SubTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 89.scale),
            cell3SubTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            cell3SubTitleLabel.topAnchor.constraint(equalTo: cell3TitleLabel.bottomAnchor, constant: 7.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell3ImageView.widthAnchor.constraint(equalToConstant: 40.scale),
            cell3ImageView.heightAnchor.constraint(equalToConstant: 40.scale),
            cell3ImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            cell3ImageView.topAnchor.constraint(equalTo: cell2Line2View.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cell3LineView.widthAnchor.constraint(equalToConstant: 8.scale),
            cell3LineView.heightAnchor.constraint(equalToConstant: 52.scale),
            cell3LineView.centerXAnchor.constraint(equalTo: cell3ImageView.centerXAnchor),
            cell3LineView.topAnchor.constraint(equalTo: cell3ImageView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cell4TitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 89.scale),
            cell4TitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            cell4TitleLabel.topAnchor.constraint(equalTo: cell3SubTitleLabel.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell4SubTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 89.scale),
            cell4SubTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            cell4SubTitleLabel.topAnchor.constraint(equalTo: cell4TitleLabel.bottomAnchor, constant: 7.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell4ImageView.widthAnchor.constraint(equalToConstant: 40.scale),
            cell4ImageView.heightAnchor.constraint(equalToConstant: 40.scale),
            cell4ImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            cell4ImageView.topAnchor.constraint(equalTo: cell3LineView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            priceLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: trialButton.topAnchor, constant: -32.scale)
        ])
        
        NSLayoutConstraint.activate([
            trialButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 29.scale),
            trialButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -29.scale),
            trialButton.heightAnchor.constraint(equalToConstant: 48.scale),
            trialButton.bottomAnchor.constraint(equalTo: plansButton.topAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            plansButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 29.scale),
            plansButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -29.scale),
            plansButton.heightAnchor.constraint(equalToConstant: 23.scale),
            plansButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -61.scale : -21.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateTrialView {
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
            .textAlignment(.center)
            .letterSpacing(-0.44.scale)
        
        let view = UILabel()
        view.attributedText = "Paygate.FreeTrial.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCell1TitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.successColor)
            .font(Fonts.Inter.bold(size: 19.scale))
            .lineHeight(26.6.scale)
            .letterSpacing(-0.44.scale)
            .strikethroughStyle(.single)
            .strikethroughColor(Appearance.successColor)
        
        let view = UILabel()
        view.attributedText = "Paygate.FreeTrial.Cell1.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCellTitleLabel(text: String) -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.bold(size: 19.scale))
            .lineHeight(26.6.scale)
            .letterSpacing(-0.44.scale)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCellSubTitleLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView(image: String) -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: image)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLineView(color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePriceLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTrialButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.whiteColor)
            .font(Fonts.Inter.semiBold(size: 17.scale))
            .letterSpacing(-0.44.scale)
        
        let view = UIButton()
        view.setAttributedTitle("Paygate.FreeTrial.TrialButton".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.mainColor
        view.layer.cornerRadius = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePlansButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mainColor)
            .font(Fonts.Inter.regular(size: 15.scale))
            .letterSpacing(-0.14.scale)
        
        let view = TapAreaButton()
        view.setAttributedTitle("Paygate.FreeTrial.PlansButton".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCellImageBackView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 12.scale
        view.backgroundColor = Appearance.successColor.withAlphaComponent(0.16)
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
