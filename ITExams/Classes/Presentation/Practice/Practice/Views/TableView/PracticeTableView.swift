//
//  PracticeTableView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import UIKit

final class PracticeTableView: UITableView {
    private(set) lazy var elements = [PracticeTableElement]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension PracticeTableView {
    func setup(elements: [PracticeTableElement]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension PracticeTableView: UITableViewDataSource {
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
        case .examDate:
            let cell = dequeueReusableCell(withIdentifier: String(describing: PracticeTableExamDateCell.self)) as! PracticeTableExamDateCell
            return cell
        case .title(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: PracticeTableTitleCell.self)) as! PracticeTableTitleCell
            cell.setup(element: element)
            return cell
        case .dailyQuestion:
            let cell = dequeueReusableCell(withIdentifier: String(describing: PracticeTableDailyQuestionCell.self)) as! PracticeTableDailyQuestionCell
            return cell
        case .tests:
            let cell = dequeueReusableCell(withIdentifier: String(describing: PracticeTableTestsCell.self)) as! PracticeTableTestsCell
            return cell
        case .unlockPremium(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: PracticeTableUnlockPremiumCell.self)) as! PracticeTableUnlockPremiumCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension PracticeTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch elements[indexPath.row] {
        case .offset(let offset):
            return offset
        case .examDate:
            return 224.scale
        case .title, .dailyQuestion, .unlockPremium:
            return UITableView.automaticDimension
        case .tests:
            return 408.scale
        }
    }
}

// MARK: Private
private extension PracticeTableView {
    func initialize() {
        register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        register(PracticeTableExamDateCell.self, forCellReuseIdentifier: String(describing: PracticeTableExamDateCell.self))
        register(PracticeTableTitleCell.self, forCellReuseIdentifier: String(describing: PracticeTableTitleCell.self))
        register(PracticeTableDailyQuestionCell.self, forCellReuseIdentifier: String(describing: PracticeTableDailyQuestionCell.self))
        register(PracticeTableTestsCell.self, forCellReuseIdentifier: String(describing: PracticeTableTestsCell.self))
        register(PracticeTableUnlockPremiumCell.self, forCellReuseIdentifier: String(describing: PracticeTableUnlockPremiumCell.self))
        
        dataSource = self
        delegate = self
    }
}
