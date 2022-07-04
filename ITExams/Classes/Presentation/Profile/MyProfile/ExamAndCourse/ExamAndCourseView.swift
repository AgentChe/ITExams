//
//  ExamAndCourseView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 04.07.2022.
//

import UIKit

final class ExamAndCourseView: UIView {
    lazy var backButton = makeBackButton()
    lazy var headerLabel = makeLabel()
    lazy var titleLabel = makeLabel()
    lazy var subTitleLabel = makeLabel()
    lazy var tableView = makeTableView()
    lazy var button = makeButton()
    lazy var preloader = makePreloader()
    
    private lazy var tableViewTopConstraint = NSLayoutConstraint()
    
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
extension ExamAndCourseView {
    func update(asExamMode: Bool) {
        backButton.isHidden = asExamMode
        
        let headerAttrs = TextAttributes()
            .textColor(Appearance.mainColor)
            .font(Fonts.Inter.bold(size: 17.scale))
            .lineHeight(20.4.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        
        let titleAttrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.bold(size: 28.scale))
            .lineHeight(33.6.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        
        let subTitleAttrs = TextAttributes()
            .textColor(Appearance.greyColor)
            .font(Fonts.Inter.regular(size: 15.scale))
            .lineHeight(22.5.scale)
            .letterSpacing(-0.14.scale)
            .textAlignment(.center)
        
        let header = asExamMode ? "Onboarding.Exams.Header".localized : "Onboarding.Course.Header".localized
        let title = asExamMode ? "Onboarding.Exams.Title".localized : "Onboarding.Course.Title".localized
        let subTitle = asExamMode ? "" : "Onboarding.Course.SubTitle".localized
        
        headerLabel.attributedText = header.attributed(with: headerAttrs)
        titleLabel.attributedText = title.attributed(with: titleAttrs)
        subTitleLabel.attributedText = subTitle.attributed(with: subTitleAttrs)
        
        tableViewTopConstraint.isActive = false
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: asExamMode ? titleLabel.bottomAnchor : subTitleLabel.bottomAnchor, constant: 4.scale)
        tableViewTopConstraint.isActive = true
        
        layoutIfNeeded()
    }
}

// MARK: Private
private extension ExamAndCourseView {
    func initialize() {
        backgroundColor = Appearance.backgroundColor
    }
}

// MARK: Make constraints
private extension ExamAndCourseView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 24.scale),
            backButton.heightAnchor.constraint(equalToConstant: 24.scale),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 49.scale : 30.scale)
        ])
        
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 44.scale : 24.scale)
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
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableViewTopConstraint,
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            button.heightAnchor.constraint(equalToConstant: 48.scale),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ExamAndCourseView {
    func makeBackButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "OCouse.Back"), for: .normal)
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
    
    func makeTableView() -> ExamAndCourseTableView {
        let view = ExamAndCourseTableView()
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
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 36.scale, height: 36.scale))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
