//
//  StepTestsTableView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 12.05.2022.
//

import UIKit

final class StepTestsTableView: UITableView {
    private lazy var elements = [PlanTest]()
    private lazy var activeSubscription = false
    private lazy var lockedStep = false
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension StepTestsTableView {
    func setup(elements: [PlanTest], activeSubscription: Bool, lockedStep: Bool) {
        self.elements = elements
        self.activeSubscription = activeSubscription
        self.lockedStep = lockedStep
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension StepTestsTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: StepTestsTableCell.self)) as! StepTestsTableCell
        cell.setup(element: elements[indexPath.section],
                   activeSubscription: activeSubscription,
                   lockedStep: lockedStep)
        return cell
    }
}

// MARK: UITableViewDelegate
extension StepTestsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(elements[indexPath.section].name)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48.scale
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        16.scale
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
}

// MARK: Private
private extension StepTestsTableView {
    func initialize() {
        register(StepTestsTableCell.self, forCellReuseIdentifier: String(describing: StepTestsTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
