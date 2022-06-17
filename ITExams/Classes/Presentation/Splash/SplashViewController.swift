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
    
    private lazy var sdkInitialize = SplashSDKInitialize(vc: self, rushSDKSignal: generateStep)
    
    private var wasAnimated = false
    
    private let generateStep: Signal<Bool>
    
    private init(generateStep: Signal<Bool>) {
        self.generateStep = generateStep
        
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.openError()
        }
        
        viewModel.step()
            .drive(onNext: { [weak self] step in
                guard let self = self else {
                    return
                }
                
                self.activity(state: .none)
                self.goNext(at: step)
            })
            .disposed(by: disposeBag)
        
        sdkInitialize.initialize { [weak self] progress in
            guard let self = self else {
                return
            }
            
            switch progress {
            case .error:
                self.activity(state: .none)
            case .initializing:
                self.activity(state: .sdkInitialize)
            case .complete:
                self.activity(state: .library)
                self.viewModel.validationComplete.accept(Void())
            }
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
    static func make(generateStep: Signal<Bool>) -> SplashViewController {
        SplashViewController(generateStep: generateStep)
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
    
    func activity(state: SplashActivity) {
        state == .none ? mainView.preloader.stopAnimating() : mainView.preloader.startAnimating()
        
        let attrs = TextAttributes()
            .textColor(Appearance.greyColor)
            .font(Fonts.Inter.regular(size: 15.scale))
            .lineHeight(22.5.scale)
            .letterSpacing(-0.14.scale)
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
