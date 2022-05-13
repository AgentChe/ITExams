//
//  SettingsViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 13.05.2022.
//

import UIKit
import RxSwift

final class SettingsViewController: UIViewController {
    lazy var mainView = SettingsView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = SettingsViewModel()
    
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
    }
}

// MARK: Make
extension SettingsViewController {
    static func make() -> SettingsViewController {
        SettingsViewController()
    }
}

// MARK: SettingsTableViewDelegate
extension SettingsViewController: SettingsTableViewDelegate {
    func settingsTableDidSelect(element: SettingsTableElement) {
        
    }
}
