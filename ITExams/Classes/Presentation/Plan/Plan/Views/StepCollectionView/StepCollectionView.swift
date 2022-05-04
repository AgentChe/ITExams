//
//  StepCollectionView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 04.05.2022.
//

import UIKit

protocol StepCollectionViewDelegate: AnyObject {
    func stepCollectionViewDidSelect(element: StepCollectionElement)
}

final class StepCollectionView: UICollectionView {
    weak var mainDelegate: StepCollectionViewDelegate?
    
    lazy var elements = [StepCollectionElement]()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension StepCollectionView {
    func setup(elements: [StepCollectionElement]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension StepCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: String(describing: StepCollectionCell.self), for: indexPath) as! StepCollectionCell
        let element = elements[indexPath.row]
        cell.setup(progress: element.step.progress, locked: element.locked)
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension StepCollectionView: UICollectionViewDelegateFlowLayout {
    
}

// MARK: Private
private extension StepCollectionView {
    func initialize() {
        register(StepCollectionCell.self, forCellWithReuseIdentifier: String(describing: StepCollectionCell.self))
        
        dataSource = self
        delegate = self
    }
}
