//
//  SplashViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.02.2022.
//

import UIKit
import RxSwift
import RxCocoa
import OtterScaleiOS

final class SplashViewController: UIViewController {
    lazy var mainView = SplashView()
    
    private lazy var viewModel = SplashViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var validationObserver = SplashReceiptValidationObserver()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.step()
            .drive(onNext: { [weak self] step in
                guard let self = self else {
                    return
                }
                
                self.goNext(at: step)
            })
            .disposed(by: disposeBag)
        
        validationObserver.observe { [weak self] in
            guard let self = self else {
                return
            }
            
            self.viewModel.validationComplete.accept(Void())
        }
    }
}

// MARK: Make
extension SplashViewController {
    static func make() -> SplashViewController {
        SplashViewController()
    }
}

// MARK: PaygateViewControllerDelegate
extension SplashViewController: PaygateViewControllerDelegate {
    func paygateDidClosed(with result: PaygateViewControllerResult) {
        goNext(at: .main)
    }
}

// MARK: Private
private extension SplashViewController {
    func goNext(at step: SplashViewModel.Step) {
        switch step {
        case .onboarding:
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = OnboardingViewController.make()
        case .main:
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = MainViewController.make()
        case .paygate:
            let vc = PaygateViewController.make()
            vc.delegate = self
            present(vc, animated: true)
        }
    }
}
