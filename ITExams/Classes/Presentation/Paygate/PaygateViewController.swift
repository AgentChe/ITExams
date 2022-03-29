//
//  PaygateViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.03.2022.
//

import UIKit
import RxSwift
import OtterScaleiOS

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
        
        viewModel.prices
            .drive(onNext: { [weak self] prices in
                guard let self = self else {
                    return
                }
                
                self.configure(prices: prices)
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
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.dismiss(with: .cancelled)
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
            .drive(onNext: { [weak self] active in
                guard let self = self else {
                    return
                }
            
                self.activityIndicator(active: active)
            })
            .disposed(by: disposeBag)
        
        trialView.trialButton.rx.tap
            .map { PaygateViewModel.Constants.lifetime }
            .bind(to: viewModel.buy)
            .disposed(by: disposeBag)
        
        plansView.continueButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                
                let id = [
                    self.plansView.lifetimeButton,
                    self.plansView.subscriptionButton
                ].first(where: { $0.isChecked })?.price?.price.id
                
                guard let id = id else {
                    return
                }
                
                self.viewModel.buy.accept(id)
            })
            .disposed(by: disposeBag)
        
        trialView.plansButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.mainView.moveToPlans()
            })
            .disposed(by: disposeBag)
        
        plansView.backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.mainView.backToTrial()
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
        
        let mode: Mode = usedProducts.contains(PaygateViewModel.Constants.monthly) ? .onlyPlans : .full
        
        let vc = PaygateViewController(mode: mode)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension PaygateViewController {
    func configure(prices: [PaygatePrice]) {
        prices.forEach { [weak self] price in
            guard let self = self else {
                return
            }

            switch price.product {
            case .lifetime:
                self.plansView.lifetimeButton.price = price
                self.trialView.setup(price: price)
            case .subscription:
                self.plansView.subscriptionButton.price = price
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
