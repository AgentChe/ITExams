//
//  OQuestionTableView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 07.06.2022.
//

import UIKit

final class OQuestionTableView: UITableView {
    private lazy var elements = [OQuestionTableElement]()
    private var didSelect: (() -> Void)!
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension OQuestionTableView {
    func setup(elements: [OQuestionTableElement], didSelect: @escaping () -> Void) {
        self.elements = elements
        self.didSelect = didSelect
        
        reloadSections(IndexSet(integer: 0), with: .fade)
    }
}

// MARK: UITableViewDataSource
extension OQuestionTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .offset:
            let cell = dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self))!
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        case .question(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: OQuestionTableQuestionCell.self)) as! OQuestionTableQuestionCell
            cell.setup(element: element)
            return cell
        case .answer(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: OQuestionTableAnswerCell.self)) as! OQuestionTableAnswerCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension OQuestionTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch elements[indexPath.row] {
        case .offset(let offset):
            return offset
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let .answer(element) = elements[indexPath.row] else {
            return
        }
        
        element.isSelected = true
        
        reloadData()
        
        allowsSelection = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.allowsSelection = true
            
            self?.didSelect()
        }
    }
}

// MARK: Private
private extension OQuestionTableView {
    func initialize() {
        register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        register(OQuestionTableQuestionCell.self, forCellReuseIdentifier: String(describing: OQuestionTableQuestionCell.self))
        register(OQuestionTableAnswerCell.self, forCellReuseIdentifier: String(describing: OQuestionTableAnswerCell.self))
        
        dataSource = self
        delegate = self
    }
}
