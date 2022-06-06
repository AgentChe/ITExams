//
//  ReviewViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 06.06.2022.
//

import UIKit
import RxSwift

final class ReviewViewController: UIViewController {
    lazy var mainView = ReviewView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = ReviewViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.elements
            .drive(Binder(self) { base, elements in
                base.mainView.tableView.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        addFilterTappedActions()
    }
}

// MARK: Make
extension ReviewViewController {
    static func make() -> ReviewViewController {
        ReviewViewController()
    }
}

// MARK: Private
private extension ReviewViewController {
    func addFilterTappedActions() {
        Observable
            .merge(
                mainView.filterView.allButton.rx.tap.map { ReviewFilter.all },
                mainView.filterView.incorrectButton.rx.tap.map { ReviewFilter.incorrect },
                mainView.filterView.correctButton.rx.tap.map { ReviewFilter.correct },
                mainView.filterView.savedButton.rx.tap.map { ReviewFilter.saved }
            )
            .bind(to: Binder(self) { base, filter in
                base.mainView.filterView.filter = filter
            })
            .disposed(by: disposeBag)
    }
}
