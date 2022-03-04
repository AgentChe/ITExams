//
//  OExamsView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 04.03.2022.
//

import UIKit

final class OExamsView: OSlideView {
    lazy var headerLabel = makeHeaderLabel()
    lazy var titleLabel = makeTitleLabel()
    lazy var tableView = makeTableView()
    lazy var button = makeButton()
    
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
        initialize()
        changeEnabled()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: OExamsTableDelegate
extension OExamsView: OExamsTableDelegate {
    func examsTableDidChangeSelected() {
        changeEnabled()
    }
}

// MARK: Private
private extension OExamsView {
    func initialize() {
        backgroundColor = Appearance.backgroundColor
        
        // TODO: получать данные с сервера
        let elements = [
            OExamsTableElement(title: "(The Computing Technology Industry Association)",
                               subTitle: "(The Computing Technology Industry Association) (The Computing Technology Industry Association) (The Computing Technology Industry Association)"),
            OExamsTableElement(title: "CompTIA",
                               subTitle: "(Amazon Web Services cloud expertise)"),
            OExamsTableElement(title: "CompTIA",
                               subTitle: "(The Computing Technology Industry Association)"),
            OExamsTableElement(title: "CompTIA",
                               subTitle: "(The Computing Technology Industry Association)"),
            OExamsTableElement(title: "(The Computing Technology Industry Association)",
                               subTitle: "(Amazon Web Services cloud expertise) (The Computing Technology Industry Association) (The Computing Technology Industry Association) (The Computing Technology Industry Association) (The Computing Technology Industry Association) (The Computing Technology Industry Association)"),
            OExamsTableElement(title: "CompTIA",
                               subTitle: "(The Computing Technology Industry Association)")
        ]
        tableView.setup(elements: elements)
    }
    
    func changeEnabled() {
        let isSelected = tableView.elements.contains(where: { $0.isSelected })
        
        button.isEnabled = isSelected
        button.alpha = isSelected ? 1 : 0.2
    }
}

// MARK: Make constraints
private extension OExamsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 94.scale : 44.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            button.heightAnchor.constraint(equalToConstant: 48.scale),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OExamsView {
    func makeHeaderLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mainColor)
            .font(Fonts.Inter.bold(size: 17.scale))
            .lineHeight(20.4.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.Exams.Header".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.bold(size: 28.scale))
            .lineHeight(33.6.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Onboarding.Exams.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> OExamsTable {
        let view = OExamsTable()
        view.mainDelegate = self
        view.showsVerticalScrollIndicator = false
        view.contentInset = UIEdgeInsets(top: 24.scale, left: 0, bottom: 24.scale, right: 0)
        view.separatorStyle = .none
        view.backgroundColor = UIColor.clear
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = 0.0
        }
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
        view.setAttributedTitle("Next".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.mainColor
        view.layer.cornerRadius = 8.scale
        view.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
