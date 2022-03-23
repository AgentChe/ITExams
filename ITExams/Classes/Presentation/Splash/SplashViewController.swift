//
//  SplashViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.02.2022.
//

import UIKit

final class SplashViewController: UIViewController {
    lazy var mainView = SplashView()
    
    private lazy var viewModel = SplashViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.openPaygate()
//            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = OnboardingViewController.make()
        }
    }
    
    // TODO
    func openPaygate() {
        let vc = PaygateViewController.make()
        present(vc, animated: true)
    }
}

// MARK: Make
extension SplashViewController {
    static func make() -> SplashViewController {
        SplashViewController()
    }
}
