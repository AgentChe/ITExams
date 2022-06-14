//
//  PracticeViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import UIKit
import RxSwift

final class PracticeViewController: UIViewController {
    lazy var mainView = PracticeView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = PracticeViewModel()
    
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
        
        viewModel.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
            })
            .disposed(by: disposeBag)
        
        viewModel.elements
            .drive(Binder(self) { base, elements in
                base.mainView.tableView.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        mainView.tableView.mainDelegate = self
    }
}

// MARK: Make
extension PracticeViewController {
    static func make() -> PracticeViewController {
        PracticeViewController()
    }
}

// MARK: PracticeTableViewDelegate
extension PracticeViewController: PracticeTableViewDelegate {
    func practiceTableDidTappedDailyQuestion() {
        TestCoordinator.shared.start(testType: .qotd, from: self)
    }
    
    func practiceTableDidTappedRandomTest() {
        TestCoordinator.shared.start(testType: .randomSet, from: self)
    }
    
    func practiceTableDidTappedMissedTest() {
        // TODO: empty screen
        TestCoordinator.shared.start(testType: .failedSet, from: self)
    }
    
    func practiceTableDidTappedQuickTest() {
        
    }
    
    func practiceTableDidTappedSavedTest() {
        // TODO: empty screen
        TestCoordinator.shared.start(testType: .saved, from: self)
    }
    
    func practiceTableDidTappedCusomTest() {
        
    }
    
    func practiceTableDidTappedUnlockPremium() {
        let vc = PaygateViewController.make()
        present(vc, animated: true)
    }
}

// MARK: Private
private extension PracticeViewController {
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
        let showAnimating = activity && mainView.tableView.elements.isEmpty
        showAnimating ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
}
