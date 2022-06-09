//
//  PracticeViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import RxSwift
import RxCocoa

final class PracticeViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var activity = RxActivityIndicator()
    
    lazy var elements = makeElements()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension PracticeViewModel {
    func makeElements() -> Driver<[PracticeTableElement]> {
        .empty()
    }
}
