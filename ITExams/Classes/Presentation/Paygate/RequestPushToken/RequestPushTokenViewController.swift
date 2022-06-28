//
//  RequestPushTokenViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 28.06.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class RequestPushTokenViewController: UIViewController {
    lazy var mainView = RequestPushTokenView()
    
    private lazy var viewModel = RequestPushTokenViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private let completion: (() -> Void)
    
    private init(completion: @escaping (() -> Void)) {
        self.completion = completion
        
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
        
        PushNotificationsManager.shared.add(observer: self)
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.openError()
        }
        
        viewModel.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
            })
            .disposed(by: disposeBag)
        
        mainView.remindButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.requestPushToken()
            })
            .disposed(by: disposeBag)
        
        Driver
            .merge(
                mainView.laterButton.rx.tap.asDriver(),
                viewModel.saved
            )
            .drive(Binder(self) { base, void in
                base.dismiss()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateShow()
    }
}

// MARK: Make
extension RequestPushTokenViewController {
    static func make(completion: @escaping (() -> Void)) -> RequestPushTokenViewController {
        let vc = RequestPushTokenViewController(completion: completion)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: RequestPushTokenViewController
extension RequestPushTokenViewController: PushNotificationsDelegate {
    func pushNotificationsDidReceive(authorizationStatus: PushNotificationsAuthorizationStatus) {}
    func pushNotificationsDidReceive(model: PushNotificationsModel) {}
    
    func pushNotificationsDidReceive(token: String?) {
        if let token = token {
            viewModel.newToken.accept(token)
        } else {
            dismiss()
        }
    }
}

// MARK: Private
private extension RequestPushTokenViewController {
    func requestPushToken() {
        PushNotificationsManager.shared.retriveAuthorizationStatus { status in
            switch status {
            case .denied:
                guard
                    let bundleIdentifier = Bundle.main.bundleIdentifier,
                    let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier),
                    UIApplication.shared.canOpenURL(appSettings)
                else {
                    return
                }
                
                UIApplication.shared.open(appSettings)
            case .notDetermined, .authorized:
                PushNotificationsManager.shared.requestAuthorization()
            }
        }
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
    
    func activity(_ activity: Bool) {
        mainView.remindButton.isHidden = activity
        mainView.laterButton.isHidden = activity
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
    
    func animateShow() {
        mainView.containerBottomConstraint.isActive = false
        mainView.containerBottomConstraint.constant = 0
        mainView.containerBottomConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mainView.dimmedView.alpha = 0.2
            self?.mainView.layoutIfNeeded()
        })
    }
    
    func dismiss() {
        PushNotificationsManager.shared.remove(observer: self)
        
        animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                self?.completion()
            }
        }
    }
    
    func animateDismiss(completion: @escaping (() -> Void)) {
        mainView.containerBottomConstraint.isActive = false
        mainView.containerBottomConstraint.constant = ScreenSize.isIphoneXFamily ? 472.scale : 422.scale
        mainView.containerBottomConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mainView.dimmedView.alpha = 0
            self?.mainView.layoutIfNeeded()
        }, completion: { result in
            completion()
        })
    }
}
