//
//  StudyModeViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 16.05.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class StudyModeViewController: UIViewController {
    lazy var mainView = StudyModeView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = StudyModeViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.currentMode
            .drive(onNext: { [weak self] currentMode in
                guard let self = self else {
                    return
                }
                
                self.mainView.setup(mode: currentMode)
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
                
                self.setNewMode()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension StudyModeViewController {
    static func make() -> StudyModeViewController {
        let vc = StudyModeViewController()
        vc.modalPresentationStyle = .popover
        return vc
    }
}

// MARK: Private
private extension StudyModeViewController {
    func setNewMode() {
        let cells = [mainView.cell1, mainView.cell2, mainView.cell3]
        
        guard let element = cells.first(where: { $0.isChecked })?.element else {
            return
        }
        
        viewModel.newMode.accept(element.code)
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
