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
}

// MARK: Make
extension PlanViewController {
    static func make() -> PlanViewController {
        PlanViewController()
    }
}
