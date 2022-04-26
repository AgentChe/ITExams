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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.elements
            .drive(onNext: { [weak self] elements in
                self?.mainView.tableView.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        mainView.cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.saveButton.rx.tap
            .flatMapLatest { [weak self] _ -> Single<Void> in
                guard let self = self else {
                    return .never()
                }
                
                guard let (exam, course) = self.getSelected() else {
                    return .never()
                }
                
                return self.viewModel
                    .save(exam: exam, course: course)
            }
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension CoursesViewController {
    static func make() -> CoursesViewController {
        CoursesViewController()
    }
}

// MARK: Private
private extension CoursesViewController {
    func getSelected() -> (Exam, Course)? {
        for i in 0...(mainView.tableView.elements.count - 1) {
            let element = mainView.tableView.elements[i]
            
            switch element {
            case .exam(let examElement):
                if let courseElement = examElement.courses.first(where: { $0.isSelected }) {
                    return (examElement.exam, courseElement.course)
                }
            default:
                continue
            }
        }
        
        return nil
    }
}
