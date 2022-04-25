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
    }
}

// MARK: Make
extension PlanViewController {
    static func make() -> PlanViewController {
        PlanViewController()
    }
}
