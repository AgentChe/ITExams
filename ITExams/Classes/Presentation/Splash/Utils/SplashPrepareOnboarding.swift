//
//  SplashPrepareOnboarding.swift
//  ITExams
//
//  Created by Андрей Чернышев on 07.06.2022.
//

import RxSwift
import RxCocoa
import UIKit

final class SplashPrepareOnboarding {
    enum Progress {
        case error, downloading, complete
    }
    
    private var questionManager = QuestionManager()
    
    private var disposable: Disposable?
    
    private var handler: ((Progress) -> Void)?
    
    private weak var vc: UIViewController?
    
    init(vc: UIViewController) {
        self.vc = vc
    }
}

// MARK: Public
extension SplashPrepareOnboarding {
    func prepare(handler: @escaping ((Progress) -> Void)) {
        self.handler = handler
        
        obtainTest()
    }
}

// MARK: Private
private extension SplashPrepareOnboarding {
    func obtainTest() {
        disposable?.dispose()
        
        send(progress: .downloading)
        
        disposable = questionManager.obtainOnboardingTest(forceUpdate: true)
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] test in
                guard let self = self else {
                    return
                }
                
                let success = test != nil
                
                if success {
                    self.send(progress: .complete)
                } else {
                    self.send(progress: .error)
                    self.openError()
                }
            })
    }
    
    func openError() {
        let tryAgainVC = TryAgainViewController.make { [weak self] in
            guard let self = self else {
                return
            }
            
            self.obtainTest()
        }
        vc?.present(tryAgainVC, animated: true)
    }
    
    func send(progress: Progress) {
        guard let handler = handler else {
            return
        }
        
        handler(progress)
    }
}
