//
//  PaygateViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.03.2022.
//

import UIKit
import RxSwift
import OtterScaleiOS
import RushSDK

final class PaygateViewController: UIViewController {
    enum Mode {
        case full, onlyPlans
    }
    
    weak var delegate: PaygateViewControllerDelegate?
    
    lazy var mainView = PaygateView()
    
    private lazy var trialView = PaygateTrialView()
    private lazy var plansView = PaygatePlansView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = PaygateViewModel()
    
    private let mode: Mode
    
    private init(mode: Mode) {
        self.mode = mode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.questionsCount
            .drive(Binder(self) { base, questionsCount in
                base.configure(questionsCount: questionsCount)
            })
            .disposed(by: disposeBag)
        
        viewModel.monetization
            .drive(Binder(self) { base, monetization in
                base.configure(monetization: monetization)
            })
            .disposed(by: disposeBag)
        
        viewModel.prices
            .drive(Binder(self) { base, prices in
                base.configure(prices: prices)
            })
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                plansView.termsOfServiceButton.rx.tap.map { GlobalDefinitions.termsOfServiceUrl },
                plansView.privacyPolicyButton.rx.tap.map { GlobalDefinitions.privacyPolicyUrl }
            )
            .subscribe(onNext: { path in
                guard let url = URL(string: path) else {
                    return
                }
                
                UIApplication.shared.open(url, options: [:])
            })
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                trialView.closeButton.rx.tap.asObservable(),
                plansView.closeButton.rx.tap.asObservable()
            )
            .bind(to: Binder(self) { base, void in
                base.dismiss(with: .cancelled)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .buyed
            .emit(onNext: { [weak self] result in
                if !result {
                    Toast.notify(with: "Paygate.Purchase.Failed".localized, style: .danger)
                    return
                }
                
                self?.dismiss(with: .bied)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .restored
            .emit(onNext: { [weak self] result in
                if !result {
                    Toast.notify(with: "Paygate.Purchase.Failed".localized, style: .danger)
                    return
                }
                
                self?.dismiss(with: .restored)
            })
            .disposed(by: disposeBag)
        
        viewModel.activityIndicator
            .drive(Binder(self) { base, active in
                base.activityIndicator(active: active)
            })
            .disposed(by: disposeBag)
        
        trialView.trialButton.rx.tap
            .map { PaygateViewModel.Constants.monthlyTrial }
            .bind(to: viewModel.buy)
            .disposed(by: disposeBag)
        
        plansView.continueButton.rx.tap
            .bind(to: Binder(self) { base, void in
                let id = [
                    base.plansView.lifetimeButton,
                    base.plansView.subscriptionButton
                ].first(where: { $0.isChecked })?.price?.price.id
                
                guard let id = id else {
                    return
                }
                
                base.viewModel.buy.accept(id)
            })
            .disposed(by: disposeBag)
        
        trialView.plansButton.rx.tap
            .bind(to: Binder(self) { base, void in
                AmplitudeManager.shared
                    .logEvent(name: "Paygate Screen", parameters: ["type": "all_plans"])
                
                base.mainView.moveToPlans()
            })
            .disposed(by: disposeBag)
        
        plansView.backButton.rx.tap
            .bind(to: Binder(self) { base, void in
                AmplitudeManager.shared
                    .logEvent(name: "Paygate Screen", parameters: ["type": "trial_plan"])
                
                base.mainView.backToTrial()
            })
            .disposed(by: disposeBag)
        
        plansView.lifetimeButton.isChecked = true
        
        mainView.register(trialView: trialView, plansView: plansView, mode: mode)
        
        configureMode()
    }
}

// MARK: Make
extension PaygateViewController {
    static func make() -> PaygateViewController {
        let usedProducts = OtterScale.shared.getUsedProducts().map { products -> [String] in
            products.appleAppStore + products.googlePlay + products.stripe
        } ?? []
        
        let mode: Mode = usedProducts.contains(PaygateViewModel.Constants.monthlyTrial) ? .onlyPlans : .full
        
        let vc = PaygateViewController(mode: mode)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension PaygateViewController {
    func configure(questionsCount: Int) {
        trialView.setup(questionsCount: questionsCount)
        plansView.setup(questionsCount: questionsCount)
    }
    
    func configure(monetization: Monetization) {
        trialView.closeButton.isHidden = monetization == .block
        plansView.closeButton.isHidden = monetization == .block
    }
    
    func configure(prices: [PaygatePrice]) {
        prices.forEach { [weak self] price in
            guard let self = self else {
                return
            }
            
            switch price.product {
            case .lifetime:
                self.plansView.lifetimeButton.price = price
            case .monthly:
                self.plansView.subscriptionButton.price = price
            case .monthlyTrial:
                self.trialView.setup(price: price)
            }
        }
    }
    
    func configureMode() {
        plansView.backButton.isHidden = mode == .onlyPlans
    }
    
    func dismiss(with result: PaygateViewControllerResult) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.delegate?.paygateDidClosed(with: result)
        }
    }
    
    func activityIndicator(active: Bool) {
        active ? trialView.preloader.startAnimating() : trialView.preloader.stopAnimating()
        active ? plansView.preloader.startAnimating() : plansView.preloader.stopAnimating()
        
        trialView.priceLabel.isHidden = active
        trialView.trialButton.isHidden = active
        plansView.lifetimeButton.isHidden = active
        plansView.subscriptionButton.isHidden = active
        plansView.continueButton.isHidden = active
    }
}
