//
//  PracticeViewController.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import UIKit
import RxSwift
import RushSDK

final class PracticeViewController: UIViewController {
    lazy var mainView = PracticeView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = PracticeViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeManager.shared
            .logEvent(name: "Study Screen")
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.openError()
        }
        
        viewModel.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
            })
            .disposed(by: disposeBag)
        
        viewModel.elements
            .drive(Binder(self) { base, elements in
                base.mainView.tableView.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        mainView.tableView.mainDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
}

// MARK: Make
extension PracticeViewController {
    static func make() -> PracticeViewController {
        PracticeViewController()
    }
}

// MARK: PracticeTableViewDelegate
extension PracticeViewController: PracticeTableViewDelegate {
    func practiceTableDidTappedTrackExamDate() {
        let vc = PracticeDateOfExamViewController.make(mode: .set)
        present(vc, animated: false)
    }
    
    func practiceTableDidTappedChangeExamDate() {
        let vc = PracticeDateOfExamViewController.make(mode: .change)
        present(vc, animated: false)
    }
    
    func practiceTableDidTappedDailyQuestion() {
        AmplitudeManager.shared
            .logEvent(name: "Study Tap", parameters: ["what": "question of the day"])
        
        TestCoordinator.shared.start(testType: .qotd, from: self)
    }
    
    func practiceTableDidTappedRandomTest() {
        AmplitudeManager.shared
            .logEvent(name: "Study Tap", parameters: ["what": "random set"])
        
        TestCoordinator.shared.start(testType: .randomSet, from: self)
    }
    
    func practiceTableDidTappedMissedTest(questionsCount: Int) {
        AmplitudeManager.shared
            .logEvent(name: "Study Tap", parameters: ["what": "missed questions"])
        
        if questionsCount == 0 {
            let vc = TestEmptyViewController.make(mode: .noMissed)
            vc.delegate = self
            present(vc, animated: true)
        } else {
            TestCoordinator.shared.start(testType: .failedSet, from: self)
        }
    }
    
    func practiceTableDidTappedQuickTest() {
        AmplitudeManager.shared
            .logEvent(name: "Study Tap", parameters: ["what": "quick questions"])
        
        TestCoordinator.shared.start(testType: .quick, from: self)
    }
    
    func practiceTableDidTappedSavedTest(questionsCount: Int) {
        AmplitudeManager.shared
            .logEvent(name: "Study Tap", parameters: ["what": "saved questions"])
        
        if questionsCount == 0 {
            let vc = TestEmptyViewController.make(mode: .noSaved)
            vc.delegate = self
            present(vc, animated: true)
        } else {
            TestCoordinator.shared.start(testType: .saved, from: self)
        }
    }
    
    func practiceTableDidTappedCustomTest() {
        AmplitudeManager.shared
            .logEvent(name: "Study Tap", parameters: ["what": "custom test"])
        
        let vc = CustomMadeTestViewController.make()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func practiceTableDidTappedUnlockPremium() {
        let vc = PaygateViewController.make()
        present(vc, animated: true)
    }
}

// MARK: TestEmptyViewControllerDelegate
extension PracticeViewController: TestEmptyViewControllerDelegate {
    func testEmptyDidTappedTakeTest() {
        TestCoordinator.shared.start(testType: .quick, from: self)
    }
}

// MARK: CustomMadeTestViewControllerDelegate
extension PracticeViewController: CustomMadeTestViewControllerDelegate {
    func customMadeTestViewControllerDidStart(attributes: CustomTestAttributes) {
        TestCoordinator.shared.start(testType: .custom(attributes), from: self)
    }
}

// MARK: Private
private extension PracticeViewController {
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
        let showAnimating = activity && mainView.tableView.elements.isEmpty
        showAnimating ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
}
