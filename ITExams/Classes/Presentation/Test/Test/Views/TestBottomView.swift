//
//  TestBottomView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 08.06.2022.
//

import UIKit

final class TestBottomView: GradientView {
    enum State {
        case confirm, submit, back, hidden
    }
    
    lazy var bottomButton = makeBottomButton()
    lazy var nextButton = makeNextButton()
    lazy var preloader = makePreloader()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if bottomButton.isHidden && nextButton.isHidden {
            return false
        }
        
        return bottomButton.frame.contains(point)
            || nextButton.frame.contains(point)
    }
}

// MARK: Public
extension TestBottomView {
    func setup(state: TestBottomView.State) {
        let attrs = TextAttributes()
            .font(Fonts.Inter.semiBold(size: 17.scale))
            .letterSpacing(-0.44.scale)
            .textColor(Appearance.whiteColor)
            .textAlignment(.center)
        
        switch state {
        case .confirm:
            bottomButton.setAttributedTitle("Question.Continue".localized.attributed(with: attrs), for: .normal)
        case .submit:
            bottomButton.setAttributedTitle("Question.Submit".localized.attributed(with: attrs), for: .normal)
        case .back:
            bottomButton.setAttributedTitle("Question.BackToStudying".localized.attributed(with: attrs), for: .normal)
        case .hidden:
            break
        }
        
        bottomButton.isHidden = state == .hidden
    }
}

// MARK: Private
private extension TestBottomView {
    func initialize() {
        gradientLayer.colors = [
            UIColor(integralRed: 248, green: 248, blue: 248, alpha: 0).cgColor,
            UIColor(integralRed: 248, green: 248, blue: 248, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.locations = [0, 0.5]
    }
}

// MARK: Make constraints
private extension TestBottomView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            bottomButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            bottomButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            bottomButton.topAnchor.constraint(equalTo: topAnchor, constant: 40.scale),
            bottomButton.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
        
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            nextButton.topAnchor.constraint(equalTo: topAnchor, constant: 40.scale),
            nextButton.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            preloader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            preloader.topAnchor.constraint(equalTo: topAnchor, constant: 40.scale),
            preloader.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension TestBottomView {
    func makeBottomButton() -> UIButton {
        let view = UIButton()
        view.layer.cornerRadius = 8.scale
        view.backgroundColor = Appearance.mainColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeNextButton() -> UIButton {
        let attrs = TextAttributes()
            .font(Fonts.Inter.semiBold(size: 17.scale))
            .letterSpacing(-0.44.scale)
            .textColor(Appearance.whiteColor)
            .textAlignment(.center)
        
        let view = UIButton()
        view.setAttributedTitle("Question.NextQuestion".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 8.scale
        view.backgroundColor = Appearance.mainColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> TestBottomSpinner {
        let view = TestBottomSpinner()
        view.isUserInteractionEnabled = false   
        view.layer.cornerRadius = 8.scale
        view.backgroundColor = Appearance.mainColor
        view.stop()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
