//
//  SplashViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.02.2022.
//

import RxSwift
import RxCocoa
import OtterScaleiOS

final class SplashViewModel {
    enum Step {
        case onboarding, main, paygate
    }
    
    lazy var validationComplete = PublishRelay<Void>()
    
    private lazy var paygateManager = PaygateManager()
    private lazy var sessionManager = SessionManager()
    private lazy var profileManager = ProfileManager()
    
    func step() -> Driver<Step> {
        handleValidationComplete()
            .flatMap { [weak self] _ -> Single<Void> in
                guard let self = self else {
                    return .never()
                }
                
                return self.library()
            }
            .flatMap { [weak self] _ -> Single<Step> in
                guard let self = self else {
                    return .never()
                }
                
                return self.makeStep()
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}

// MARK: Private
private extension SplashViewModel {
    func handleValidationComplete() -> Observable<Void> {
        validationComplete.flatMapLatest { [weak self] _ -> Single<Void> in
            guard let self = self else {
                return .never()
            }
            
            let otterScaleID = OtterScale.shared.getInternalID()
            
            let complete: Single<Void>
            
            if let cachedToken = self.sessionManager.getSession()?.userToken {
                if cachedToken != otterScaleID {
                    complete = self.profileManager.syncTokens(oldToken: cachedToken, newToken: otterScaleID)
                } else {
                    complete = .deferred { .just(Void()) }
                }
            } else {
                complete = self.profileManager.login(userToken: otterScaleID)
            }
            
            return complete.flatMap { [weak self] _ -> Single<Void> in
                guard let self = self else {
                    return .never()
                }
                
                let session = Session(userToken: otterScaleID)
                self.sessionManager.store(session: session)
                
                return .deferred { .just(Void()) }
            }
        }
    }
    
    func library() -> Single<Void> {
        paygateManager
            .retrieveMonetization(forceUpdate: true)
            .catchAndReturn(nil)
            .mapToVoid()
    }
    
    func makeStep() -> Single<Step> {
        Single<Step>
            .create { event in
                let step: Step
                
                if !OnboardingViewController.wasViewed() {
                    step = .onboarding
                } else if self.needPayment() {
                    step = .paygate
                } else {
                    step = .main
                }
                
                event(.success(step))
                
                return Disposables.create()
            }
    }
    
    func needPayment() -> Bool {
        let activeSubscription = sessionManager.hasActiveSubscriptions()
        return !activeSubscription
    }
}
