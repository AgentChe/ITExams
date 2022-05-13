//
//  MyProfileViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 13.05.2022.
//

import UIKit
import RxSwift

final class MyProfileViewController: UIViewController {
    lazy var mainView = MyProfileView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = MyProfileViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.elements
            .drive(onNext: { [weak self] elements in
                self?.mainView.tableView.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        mainView.tableView.mainDelegate = self
    }
}

// MARK: Make
extension MyProfileViewController {
    static func make() -> MyProfileViewController {
        let vc = MyProfileViewController()
        vc.navigationItem.title = "MyProfile.Title".localized
        return vc
    }
}

// MARK: MyProfileTableViewDelegate
extension MyProfileViewController: MyProfileTableViewDelegate {
    func myProfileDidSelect(element: MyProfileTableElement) {
        switch element {
        case .dateOfExam:
            break
        case .exams:
            break
        case .course:
            break
        case .studyMode:
            break
        case .dailyGoal:
            break
        case .resetProgress:
            break
        }
    }
}
