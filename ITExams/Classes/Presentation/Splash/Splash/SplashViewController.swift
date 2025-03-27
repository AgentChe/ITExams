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
    private lazy var mainView = SplashView()
    
    private lazy var viewModel = SplashViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private var wasAnimated = false
    
    private lazy var sdkInitialize = SplashReceiptValidationObserver()
    
    private lazy var didSDKConfiguredTrigger = PublishRelay<Void>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            self?.open(error: error) ?? .never()
        }
        
        let output = viewModel.configure(input: SplashViewModel.Input(
            didSDKConfigured: didSDKConfiguredTrigger.asSignal()
        ))

        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)

        sdkInitialize.observe { [weak self] in
            self?.didSDKConfiguredTrigger.accept(Void())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !wasAnimated else {
            return
        }
        
        wasAnimated = true
        
        mainView.compressImage { [weak self] in
            self?.mainView.wave()
        }
    }
}

// MARK: Make
extension SplashViewController {
    static func make() -> SplashViewController {
        SplashViewController()
    }
}

// MARK: Private
private extension SplashViewController {
    func route(_ route: SplashViewModel.Route) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
            self?.goNext(route)
        }
    }
    
    func goNext(_ route: SplashViewModel.Route) {
        switch route {
        case .onboarding:
            UIApplication.shared.keyWindow?.rootViewController = OnboardingViewController.make()
        case .main:
            UIApplication.shared.keyWindow?.rootViewController = MainViewController.make()
        case .paygateTransitionMain:
            let vc = PaygateViewController.make { [weak self] in
                self?.goNext(.main)
            }
            present(vc, animated: true)
        }
    }
    
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self else { return Disposables.create() }
                
                let vc = TryAgainViewController.make() {
                    observe.onNext(())
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
}
