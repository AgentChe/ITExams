//
//  PaygatePlansCell.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.03.2022.
//

import UIKit

final class PaygatePlansCell: UIView {
    lazy var imageView = makeImageView()
    lazy var label = makeLabel()
    
    private let text: String
    
    init(text: String) {
        self.text = text
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension PaygatePlansCell {
    func initialize() {
        backgroundColor = Appearance.backgroundColor
    }
}

// MARK: Make constraints
private extension PaygatePlansCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 21.scale),
            imageView.heightAnchor.constraint(equalToConstant: 21.scale),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 45.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygatePlansCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Paygate.Check")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.regular(size: 15.scale))
            .lineHeight(22.5.scale)
            .letterSpacing(-0.14.scale)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
