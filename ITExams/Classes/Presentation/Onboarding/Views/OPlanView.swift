//
//  OPlanView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 10.03.2022.
//

import UIKit
import RxSwift

final class OPlanView: OSlideView {
    weak var combineData: OnboardingCombineData?
    
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var gridView = makeGridView()
    lazy var column1TitleLabel = makeColumn1TitleLabel()
    lazy var column1View = makeColumn1View()
    lazy var column1PeriodLabel = makeColumn1PeriodLabel()
    lazy var column2TitleLabel = makeColumn2TitleLabel()
    lazy var column2View = makeColumn2View()
    lazy var column2PeriodLabel = makeColumn2PeriodLabel()
    lazy var button = makeButton()
    
    private lazy var column1Height = NSLayoutConstraint()
    private lazy var column2Height = NSLayoutConstraint()
    
    private lazy var disposeBag = DisposeBag()
    
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
        initialize()
        change(enabled: false)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func moveToThis() {
        super.moveToThis()
        
        openUp()
    }
}

// MARK: Private
private extension OPlanView {
    func initialize() {
        backgroundColor = Appearance.backgroundColor
        
        button.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                
                // TODO: отправка и сохранение данных
                
                self.onNext()
            })
            .disposed(by: disposeBag)
    }
    
    func prepare() {
        gridView.alpha = 0
        column1TitleLabel.alpha = 0
        column1PeriodLabel.alpha = 0
        column2TitleLabel.alpha = 0
        column2PeriodLabel.alpha = 0
    }
    
    func openUp() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else {
                return
            }
            
            self.gridView.alpha = 1
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.showPeriods()
        })
    }
    
    func showPeriods() {
        UIView.animate(withDuration: 1, animations: { [weak self] in
            guard let self = self else {
                return
            }
            
            self.column1PeriodLabel.alpha = 1
            self.column2PeriodLabel.alpha = 1
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.showColumns()
        })
    }
    
    func showColumns() {
        column1Height.constant = 60.scale
        column2Height.constant = 222.scale
        
        UIView.animate(withDuration: 2, animations: { [weak self] in
            guard let self = self else {
                return
            }
            
            self.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.showTitles()
        })
    }
    
    func showTitles() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else {
                return
            }
            
            self.column1TitleLabel.alpha = 1
            self.column2TitleLabel.alpha = 1
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.change(enabled: true)
        })
    }
    
    func change(enabled: Bool) {
        button.isEnabled = enabled
        button.alpha = enabled ? 1 : 0.2
    }
}

// MARK: Make constraints
private extension OPlanView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant:ScreenSize.isIphoneXFamily ? 126.scale : 70.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.scale)
        ])
        
        NSLayoutConstraint.activate([
            gridView.widthAnchor.constraint(equalToConstant: 335.scale),
            gridView.heightAnchor.constraint(equalToConstant: 223.scale),
            gridView.centerXAnchor.constraint(equalTo: centerXAnchor),
            gridView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 77.scale)
        ])
        
        NSLayoutConstraint.activate([
            column1TitleLabel.centerXAnchor.constraint(equalTo: column1View.centerXAnchor),
            column1TitleLabel.bottomAnchor.constraint(equalTo: column1View.topAnchor, constant: -12.scale)
        ])
        
        column1Height = column1View.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            column1View.widthAnchor.constraint(equalToConstant: 82.scale),
            column1Height,
            column1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 84.scale),
            column1View.bottomAnchor.constraint(equalTo: gridView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            column1PeriodLabel.centerXAnchor.constraint(equalTo: column1View.centerXAnchor),
            column1PeriodLabel.topAnchor.constraint(equalTo: column1View.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            column2TitleLabel.centerXAnchor.constraint(equalTo: column2View.centerXAnchor),
            column2TitleLabel.bottomAnchor.constraint(equalTo: column2View.topAnchor, constant: -12.scale)
        ])
        
        column2Height = column2View.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            column2View.widthAnchor.constraint(equalToConstant: 82.scale),
            column2Height,
            column2View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 207.scale),
            column2View.bottomAnchor.constraint(equalTo: gridView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            column2PeriodLabel.centerXAnchor.constraint(equalTo: column2View.centerXAnchor),
            column2PeriodLabel.topAnchor.constraint(equalTo: column2View.bottomAnchor, constant: 12.scale)
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
private extension OPlanView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.bold(size: 28.scale))
            .lineHeight(33.6.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Onboarding.PlanView.Title".localized.attributed(with: attrs)
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
        view.attributedText = "Onboarding.PlanView.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeGridView() -> OPlanGridView {
        let view = OPlanGridView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeColumn1TitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor)
            .font(Fonts.Inter.semiBold(size: 15.scale))
            .lineHeight(18.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.PlanView.Column1.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeColumn1View() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.fourthColor
        view.layer.cornerRadius = 8.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeColumn1PeriodLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor.withAlphaComponent(0.4))
            .font(Fonts.Inter.semiBold(size: 15.scale))
            .lineHeight(22.5.scale)
            .letterSpacing(-0.14.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.PlanView.Column1.Period".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeColumn2TitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mainColor)
            .font(Fonts.Inter.semiBold(size: 15.scale))
            .lineHeight(18.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Onboarding.PlanView.Column2.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeColumn2View() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mainColor
        view.layer.cornerRadius = 8.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeColumn2PeriodLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.blackColor.withAlphaComponent(0.4))
            .font(Fonts.Inter.semiBold(size: 15.scale))
            .lineHeight(22.5.scale)
            .letterSpacing(-0.14.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.PlanView.Column2.Period".localized.attributed(with: attrs)
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
        view.setAttributedTitle("Onboarding.PlanView.Button".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.mainColor
        view.layer.cornerRadius = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
