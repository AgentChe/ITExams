//
//  TestCoordinator.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import UIKit

final class TestCoordinator {
    static let shared = TestCoordinator()
    
    private var testVC: TestViewController?
    private var testStatsVC: TestStatsViewController?
    
    private weak var from: UIViewController?
    
    private init() {}
}

// MARK: Public
extension TestCoordinator {
    func start(testType: TestType, from: UIViewController?) {
        self.from = from
        
        openTest(with: testType)
    }
}

// MARK: TestViewControllerDelegate
extension TestCoordinator: TestViewControllerDelegate {
    func testViewControllerDismiss() {
        testVC?.dismiss(animated: true)
        testVC = nil
    }
    
    func testViewControllerClose(finish: TestFinish) {
        testVC?.dismiss(animated: true) {
            TestCloseMediator.shared.notifyAboudTestClosed(with: finish)
        }
        testVC = nil
    }
    
    func testViewControllerNeedPayment() {
        testVC?.dismiss(animated: true) {
            let rootVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
            rootVC?.present(PaygateViewController.make(), animated: true)
        }
        testVC = nil
    }
    
    func testViewController(finish: TestFinish) {
        testStatsVC = TestStatsViewController.make(finish: finish)
        testStatsVC?.delegate = self
        
        testVC?.dismiss(animated: true) {
            Self.shared.from?.present(Self.shared.testStatsVC!, animated: true)
        }
    }
}

// MARK: TestStatsViewControllerDelegate
extension TestCoordinator: TestStatsViewControllerDelegate {
    func testStatsViewControllerDidTapped(event: TestStatsViewController.Event) {
        testStatsVC?.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            
            switch event {
            case .close:
                self.testVC = nil
            case .restart(let userTestId):
                if let testVC = self.testVC {
                    self.from?.present(testVC, animated: true) {
                        testVC.restart(userTestId: userTestId)
                    }
                }
            case .nextTest:
                self.testVC = nil
                self.openTest(with: .get(testId: nil))
            }
        }
        testStatsVC = nil
    }
}

// MARK: Private
private extension TestCoordinator {
    func openTest(with testType: TestType) {
        // TODO: activeSubscription получать внутри теста
        testVC = TestViewController.make(testType: testType, activeSubscription: true)
        testVC?.delegate = self
        from?.present(testVC!, animated: true)
    }
}
