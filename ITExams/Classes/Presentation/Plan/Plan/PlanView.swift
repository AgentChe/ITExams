//
//  PlanView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 30.03.2022.
//

import UIKit

final class PlanView: UIView {
    lazy var headerView = makeHeaderView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstrainsts()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension PlanView {
    func initialize() {
        backgroundColor = Appearance.backgroundColor
    }
}

// MARK: Make constraints
private extension PlanView {
    func makeConstrainsts() {
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 167.scale : 157.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PlanView {
    func makeHeaderView() -> PlanHeaderView {
        let view = PlanHeaderView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = Appearance.secondColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
