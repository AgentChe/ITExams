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
    
    var product: PaygateProduct? {
        didSet {
            update()
        }
    }
    
    lazy var checkedView = makeCheckedView()
    lazy var nameLabel = makeLabel()
    lazy var priceLabel = makeLabel()
    lazy var discountPlaceholderView = makeDiscountPlaceholderView()
    lazy var discountLabel = makeLabel()
    lazy var bottomLabel = makeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        update()
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
        let color = isChecked ? Appearance.mainColor : Appearance.blackColor
        
        layer.borderColor = color.cgColor
        discountPlaceholderView.backgroundColor = color
        
        checkedView.isHidden = !isChecked
    }
    
    func configure() {
        guard let info = product?.info else {
            return
        }
        
        nameLabel.attributedText = info.name
            .attributed(with: TextAttributes()
                            .textColor(Appearance.blackColor)
                            .font(Fonts.Inter.bold(size: 24.scale))
                            .lineHeight(28.8.scale)
                            .letterSpacing(-0.44.scale))
        
        let slash = "/".attributed(with: TextAttributes()
                                .textColor(Appearance.blackColor)
                                .font(Fonts.Inter.semiBold(size: 19.scale))
                                .lineHeight(19.scale)
                                .letterSpacing(-0.44.scale))
        
        let priceValue = info.price.attributed(with: TextAttributes()
                                .textColor(Appearance.blackColor)
                                .font(Fonts.Inter.semiBold(size: 19.scale))
                                .lineHeight(19.scale)
                                .letterSpacing(-0.44.scale))
        let pricePeriod = info.pricePeriod.attributed(with: TextAttributes()
                                .textColor(Appearance.blackColor)
                                .font(Fonts.Inter.regular(size: 14.scale))
                                .lineHeight(14.scale)
                                .letterSpacing(-0.14.scale))
        let priceDescription = info.priceDescription?.attributed(with: TextAttributes()
                                .textColor(Appearance.blackColor)
                                .font(Fonts.Inter.regular(size: 10.scale))
                                .lineHeight(10.scale)
                                .letterSpacing(-0.14.scale))
        let price = NSMutableAttributedString()
        price.append(priceValue)
        price.append(slash)
        price.append(pricePeriod)
        if let priceDescription = priceDescription {
            price.append(priceDescription)
        }
        priceLabel.attributedText = price
        
        discountPlaceholderView.isHidden = info.discount == nil
        discountLabel.isHidden = info.discount == nil
        if let discount = info.discount {
            discountLabel.attributedText = String(format: "Paygate.Discount".localized, discount)
                .attributed(with: TextAttributes()
                                .textColor(Appearance.whiteColor)
                                .font(Fonts.Inter.semiBold(size: 13.scale))
                                .lineHeight(18.scale)
                                .letterSpacing(-0.08.scale))
            
        }
        
        let bottomPrice = info.bottomPrice?.attributed(with: TextAttributes()
                                .textColor(Appearance.blackColor)
                                .font(Fonts.Inter.bold(size: 19.scale))
                                .lineHeight(26.6.scale)
                                .letterSpacing(-0.44.scale))
        let bottomDescription = info.bottomDescription.attributed(with: TextAttributes()
                                .textColor(Appearance.blackColor)
                                .font(Fonts.Inter.regular(size: 14.scale))
                                .lineHeight(19.6.scale)
                                .letterSpacing(-0.14.scale))
        let bottom = NSMutableAttributedString()
        if let bottomPrice = bottomPrice {
            bottom.append(bottomPrice)
            bottom.append(slash)
        }
        bottom.append(bottomDescription)
        bottomLabel.attributedText = bottom
    }
}

// MARK: Make constraints
private extension PaygateProductButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            checkedView.widthAnchor.constraint(equalToConstant: 24.scale),
            checkedView.heightAnchor.constraint(equalToConstant: 24.scale),
            checkedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            checkedView.topAnchor.constraint(equalTo: topAnchor, constant: 13.scale)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 34.scale)
        ])
        
        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            priceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 69.scale)
        ])
        
        NSLayoutConstraint.activate([
            discountPlaceholderView.widthAnchor.constraint(equalToConstant: 77.scale),
            discountPlaceholderView.heightAnchor.constraint(equalToConstant: 18.scale),
            discountPlaceholderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 11.5.scale),
            discountPlaceholderView.topAnchor.constraint(equalTo: topAnchor, constant: 113.scale)
        ])
        
        NSLayoutConstraint.activate([
            discountLabel.centerXAnchor.constraint(equalTo: discountPlaceholderView.centerXAnchor),
            discountLabel.centerYAnchor.constraint(equalTo: discountPlaceholderView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            bottomLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            bottomLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateProductButton {
    func makeCheckedView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Paygate.Checked")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDiscountPlaceholderView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mainColor
        view.layer.cornerRadius = 4.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
