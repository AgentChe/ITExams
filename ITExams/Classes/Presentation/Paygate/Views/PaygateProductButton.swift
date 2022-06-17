//
//  PaygateProductButton.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.03.2022.
//

import UIKit

final class PaygateProductButton: UIButton {
    var isChecked: Bool = false {
        didSet {
            update()
        }
    }
    
    var price: PaygatePrice? {
        didSet {
            update()
        }
    }
    
    lazy var nameLabel = makeLabel()
    lazy var priceLabel = makeLabel()
    lazy var periodPriceLabel = makeLabel()
    lazy var placeholderLabel = makeLabel()
    lazy var placeholderView = makePlaceholderView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension PaygateProductButton {
    func update() {
        changeSelection()
        configure()
    }
    
    func changeSelection() {
        layer.borderColor = isChecked ? Appearance.mainColor.cgColor : UIColor.clear.cgColor
        placeholderView.backgroundColor = isChecked ? Appearance.mainColor : Appearance.greyColor.withAlphaComponent(0.3)
    }
    
    func configure() {
        guard let price = price else {
            return
        }
        
        let div: Double
        let period: String
        
        let name: String
        let placeholder: String
        switch price.product {
        case .lifetime:
            div = 53
            period = "Paygate.Week".localized
            
            name = "Paygate.Plans.Product1.Title".localized
            placeholder = "Paygate.Plans.Product1.Placeholder".localized
        case .monthly, .monthlyTrial:
            div = 4
            period = "Paygate.Week".localized
            
            name = "Paygate.Plans.Product2.Title".localized
            placeholder = "Paygate.Plans.Product2.Placeholder".localized
        }
        nameLabel.attributedText = name
            .attributed(with: TextAttributes()
                            .textColor(Appearance.blackColor)
                            .font(Fonts.Inter.bold(size: 19.scale))
                            .lineHeight(26.6.scale)
                            .letterSpacing(-0.44.scale))
        
        placeholderLabel.attributedText = placeholder
            .attributed(with: TextAttributes()
                            .textColor(Appearance.whiteColor)
                            .font(Fonts.Inter.semiBold(size: 13.scale))
                            .lineHeight(15.6.scale)
                            .letterSpacing(-0.44.scale))
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = price.price.priceLocale

        let priceDiv: Double = price.price.priceValue / div
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
        let pricePeriodResult = String(format: "%@/%@",
                                       priceDivLocalized.removingWhitespaces(),
                                       period)
 
        priceLabel.attributedText = priceResult
            .attributed(with: TextAttributes()
                            .textColor(Appearance.blackColor)
                            .font(Fonts.Inter.regular(size: 15.scale))
                            .lineHeight(22.5.scale)
                            .letterSpacing(-0.14.scale))

        periodPriceLabel.attributedText = pricePeriodResult
            .attributed(with: TextAttributes()
                            .textColor(Appearance.greyColor)
                            .font(Fonts.Inter.regular(size: 15.scale))
                            .lineHeight(22.5.scale)
                            .letterSpacing(-0.14.scale))
    }
}

// MARK: Make constraints
private extension PaygateProductButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6.scale)
        ])
        
        NSLayoutConstraint.activate([
            periodPriceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -17.scale),
            periodPriceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            placeholderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: placeholderLabel.leadingAnchor, constant: -8.scale),
            placeholderView.topAnchor.constraint(equalTo: topAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 7.scale)
        ])
        
        NSLayoutConstraint.activate([
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6.scale),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateProductButton {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePlaceholderView() -> UIView {
        let view = UIView()
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
