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
    private lazy var prepareOnboarding = SplashPrepareOnboarding(vc: self)
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity(state: .sdkInitialize)
        
        viewModel.step()
            .drive(onNext: { [weak self] step in
                guard let self = self else {
                    return
                }
                
                self.activity(state: step == .onboarding ? .prepareOnboarding : .none)
                self.goNext(at: step)
            })
            .disposed(by: disposeBag)
        
        validationObserver.observe { [weak self] in
            guard let self = self else {
                return
            }
            
            self.activity(state: .library)
            self.viewModel.validationComplete.accept(Void())
        }
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.openError()
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
            prepareOnboarding.prepare { [weak self] progress in
                guard let self = self else {
                    return
                }
                
                switch progress {
                case .error:
                    self.activity(state: .none)
                case .downloading:
                    self.activity(state: .prepareOnboarding)
                case .complete:
                    UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = OnboardingViewController.make()
                }
            }
        case .main:
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = MainViewController.make()
        case .paygate:
            let vc = PaygateViewController.make()
            vc.delegate = self
            present(vc, animated: true)
        }
    }
    
    func activity(state: SplashActivity) {
        state == .none ? mainView.preloader.stopAnimating() : mainView.preloader.startAnimating()
        
        let attrs = TextAttributes()
            .textColor(Appearance.greyColor)
            .font(Fonts.Inter.regular(size: 17.scale))
            .lineHeight(23.8.scale)
            .textAlignment(.center)
        mainView.preloaderLabel.attributedText = state.text.attributed(with: attrs)
    }
    
    func openError() -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make {
                    observe.onNext(())
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
}
