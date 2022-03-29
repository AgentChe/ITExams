//
//  PaygateView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 23.03.2022.
//

import UIKit

final class PaygateView: UIView {
    private var trialView: UIView!
    private var plansView: UIView!
    
    private lazy var trialViewWidthConstraint = NSLayoutConstraint()
    private lazy var trialViewLeadingConstraint = NSLayoutConstraint()
    private lazy var trialViewTopConstraint = NSLayoutConstraint()
    private lazy var trialViewBottomConstraint = NSLayoutConstraint()
    
    private lazy var plansViewWidthConstraint = NSLayoutConstraint()
    private lazy var plansViewLeadingConstraint = NSLayoutConstraint()
    private lazy var plansViewTopConstraint = NSLayoutConstraint()
    private lazy var plansViewBottomConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension PaygateView {
    func register(trialView: UIView, plansView: UIView, mode: PaygateViewController.Mode) {
        self.trialView = trialView
        self.plansView = plansView
        
        switch mode {
        case .full:
            trialView.translatesAutoresizingMaskIntoConstraints = false
            plansView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(trialView)
            addSubview(plansView)
            
            trialViewWidthConstraint = trialView.widthAnchor.constraint(equalToConstant: 375.scale)
            trialViewLeadingConstraint = trialView.leadingAnchor.constraint(equalTo: leadingAnchor)
            trialViewTopConstraint = trialView.topAnchor.constraint(equalTo: topAnchor)
            trialViewBottomConstraint = trialView.bottomAnchor.constraint(equalTo: bottomAnchor)
            
            plansViewWidthConstraint = plansView.widthAnchor.constraint(equalToConstant: 375.scale)
            plansViewLeadingConstraint = plansView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 375.scale)
            plansViewTopConstraint = plansView.topAnchor.constraint(equalTo: topAnchor)
            plansViewBottomConstraint = plansView.bottomAnchor.constraint(equalTo: bottomAnchor)
            
            NSLayoutConstraint.activate([
                trialViewWidthConstraint,
                trialViewLeadingConstraint,
                trialViewTopConstraint,
                trialViewBottomConstraint,
                
                plansViewWidthConstraint,
                plansViewLeadingConstraint,
                plansViewTopConstraint,
                plansViewBottomConstraint
            ])
        case .onlyPlans:
            plansView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(plansView)
            
            plansViewWidthConstraint = plansView.widthAnchor.constraint(equalToConstant: 375.scale)
            plansViewLeadingConstraint = plansView.leadingAnchor.constraint(equalTo: leadingAnchor)
            plansViewTopConstraint = plansView.topAnchor.constraint(equalTo: topAnchor)
            plansViewBottomConstraint = plansView.bottomAnchor.constraint(equalTo: bottomAnchor)
            
            NSLayoutConstraint.activate([
                plansViewWidthConstraint,
                plansViewLeadingConstraint,
                plansViewTopConstraint,
                plansViewBottomConstraint
            ])
        }
    }
    
    func moveToPlans() {
        NSLayoutConstraint.deactivate([
            trialViewLeadingConstraint,
            plansViewLeadingConstraint
        ])
        
        trialViewLeadingConstraint.constant = -375.scale
        plansViewLeadingConstraint.constant = 0
        
        NSLayoutConstraint.activate([
            trialViewLeadingConstraint,
            plansViewLeadingConstraint
        ])
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else {
                return
            }
            
            self.layoutIfNeeded()
        })
    }
    
    func backToTrial() {
        NSLayoutConstraint.deactivate([
            trialViewLeadingConstraint,
            plansViewLeadingConstraint
        ])
        
        trialViewLeadingConstraint.constant = 0
        plansViewLeadingConstraint.constant = 375.scale
        
        NSLayoutConstraint.activate([
            trialViewLeadingConstraint,
            plansViewLeadingConstraint
        ])
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else {
                return
            }
            
            self.layoutIfNeeded()
        })
    }
}

// MARK: Private
private extension PaygateView {
    func initialize() {
        backgroundColor = Appearance.backgroundColor
    }
}
