//
//  OCourseView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 07.03.2022.
//

import UIKit

final class OCourseView: OSlideView {
    lazy var backButton = makeBackButton()
    lazy var headerLabel = makeHeaderLabel()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
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

// MARK: OExamsViewDelegate
extension OCourseView: OExamsViewDelegate {
    func onbExamsDidSelected(id: String) {
        // TODO: получать данные с сервера
        
        let elements = [
            OExamsTableElement(title: "(Cloud Practitioner",
                               subTitle: "Assesses knowledge of core services and use cases, billing and pricing models, security concepts, and how cloud impacts business"),
            OExamsTableElement(title: "Certified Database",
                               subTitle: "Validates expertise in recommending, designing, and maintaining the optimal AWS database solution to improve performance"),
            OExamsTableElement(title: "(Cloud Practitioner",
                               subTitle: "Assesses knowledge of core services and use cases, billing and pricing models, security concepts, and how cloud impacts business"),
            OExamsTableElement(title: "Certified Database",
                               subTitle: "Validates expertise in recommending, designing, and maintaining the optimal AWS database solution to improve performance"),
            OExamsTableElement(title: "(Cloud Practitioner",
                               subTitle: "Assesses knowledge of core services and use cases, billing and pricing models, security concepts, and how cloud impacts business"),
            OExamsTableElement(title: "Certified Database",
                               subTitle: "Validates expertise in recommending, designing, and maintaining the optimal AWS database solution to improve performance"),
            OExamsTableElement(title: "(Cloud Practitioner",
                               subTitle: "Assesses knowledge of core services and use cases, billing and pricing models, security concepts, and how cloud impacts business"),
            OExamsTableElement(title: "Certified Database",
                               subTitle: "Validates expertise in recommending, designing, and maintaining the optimal AWS database solution to improve performance")
        ]
        tableView.setup(elements: elements)
        changeEnabled()
    }
}

// MARK: OExamsTableDelegate
extension OCourseView: OExamsTableDelegate {
    func examsTableDidChangeSelected() {
        changeEnabled()
    }
}

// MARK: Private
private extension OCourseView {
    func initialize() {
        backgroundColor = Appearance.backgroundColor
    }
    
    func changeEnabled() {
        let isSelected = tableView.elements.contains(where: { $0.isSelected })
        
        button.isEnabled = isSelected
        button.alpha = isSelected ? 1 : 0.2
    }
}

// MARK: Make constraints
private extension OCourseView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 24.scale),
            backButton.heightAnchor.constraint(equalToConstant: 24.scale),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 49.scale : 30.scale)
        ])
        
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
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 4.scale),
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
private extension OCourseView {
    func makeBackButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "OCouse.Back"), for: .normal)
        view.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeHeaderLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mainColor)
            .font(Fonts.Inter.bold(size: 17.scale))
            .lineHeight(20.4.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.Course.Header".localized.attributed(with: attrs)
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
        view.attributedText = "Onboarding.Course.Title".localized.attributed(with: attrs)
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
        view.attributedText = "Onboarding.Course.SubTitle".localized.attributed(with: attrs)
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
