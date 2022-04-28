//
//  PlanViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 30.03.2022.
//

import UIKit
import RxSwift

final class PlanViewController: UIViewController {
    lazy var mainView = PlanView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = PlanViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.planCurrent
            .drive(onNext: { [weak self] current in
                guard let self = self else {
                    return
                }

                self.mainView.headerView.currentView.setup(exam: current.exam,
                                                           course: current.course)
            })
            .disposed(by: disposeBag)

        viewModel.planStudyScore
            .drive(onNext: { [weak self] studyScore in
                guard let self = self else {
                    return
                }

                self.mainView.headerView.studyScoreView.setup(goal: studyScore.goal,
                                                              progress: studyScore.progress)
            })
            .disposed(by: disposeBag)
        
        mainView.headerView.currentView.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                
                let vc = CoursesViewController.make()
                self.present(vc, animated: true)
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
    }
}

// MARK: Make
extension PlanViewController {
    static func make() -> PlanViewController {
        PlanViewController()
    }
}

// MARK: Private
private extension PlanViewController {
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
    
    // TODO: если в списке уже есть элементы, то не показывать прелоудер
    func activity(_ activity: Bool) {
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
}
