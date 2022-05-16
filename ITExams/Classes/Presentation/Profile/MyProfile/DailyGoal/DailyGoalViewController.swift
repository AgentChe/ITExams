//
//  DailyGoalViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 16.05.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class DailyGoalViewController: UIViewController {
    lazy var mainView = DailyGoalView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = DailyGoalViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.currentTestMinutes
            .drive(onNext: { [weak self] testMinutes in
                guard let self = self else {
                    return
                }
                
                self.mainView.setup(minutes: testMinutes)
            })
            .disposed(by: disposeBag)
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.openError()
        }
        
        viewModel.activity
            .drive(onNext: { [weak self] activity in
                guard let self = self else {
                    return
                }
                
                self.activity(activity)
            })
            .disposed(by: disposeBag)
        
        viewModel.saved
            .drive(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.dismiss()
            })
            .disposed(by: disposeBag)
        
        mainView.button.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.setNewTestMinutes()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension DailyGoalViewController {
    static func make() -> DailyGoalViewController {
        let vc = DailyGoalViewController()
        vc.modalPresentationStyle = .popover
        return vc
    }
}

// MARK: Private
private extension DailyGoalViewController {
    func setNewTestMinutes() {
        let row = mainView.pickerView.selectedRow(inComponent: 0)
        let minutes = row + 1
        
        viewModel.newTestMinutes.accept(minutes)
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
        mainView.button.isHidden = activity
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
}
