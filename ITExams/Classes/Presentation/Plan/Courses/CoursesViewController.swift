//
//  CoursesViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 25.04.2022.
//

import UIKit
import RxSwift

final class CoursesViewController: UIViewController {
    lazy var mainView = CoursesView()
    
    private lazy var viewModel = CoursesViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
}

// MARK: Public
extension CoursesViewController {
    static func make() -> CoursesViewController {
        CoursesViewController()
    }
}
