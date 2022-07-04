//
//  ExamAndCourseTableView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 04.07.2022.
//

import UIKit

protocol ExamAndCourseTableDelegate: AnyObject {
    func examsAndCourseTableDidChangeSelected()
}

final class ExamAndCourseTableView: UITableView {
    weak var mainDelegate: ExamAndCourseTableDelegate?
    
    lazy var elements = [EACTableElement]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ExamAndCourseTableView {
    func setup(elements: [EACTableElement]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension ExamAndCourseTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: ExamAndCourseTableCell.self)) as! ExamAndCourseTableCell
        let element = elements[indexPath.section]
        cell.setup(title: element.title,
                   subTitle: element.subTitle,
                   isSelected: element.isSelected)
        return cell
    }
}

// MARK: UITableViewDelegate
extension ExamAndCourseTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !elements[indexPath.section].isSelected else {
            return
        }
        
        var paths = [IndexPath]()
        
        if let selectedIndex = elements.firstIndex(where: { $0.isSelected }) {
            let path = IndexPath(row: 0, section: selectedIndex)
            paths.append(path)
            
            elements[selectedIndex].isSelected = false
        }
        
        paths.append(indexPath)
        
        elements[indexPath.section].isSelected = true
        
        reloadRows(at: paths, with: .automatic)
        
        mainDelegate?.examsAndCourseTableDidChangeSelected()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        16.scale
    }
}

// MARK: Private
private extension ExamAndCourseTableView {
    func initialize() {
        register(ExamAndCourseTableCell.self, forCellReuseIdentifier: String(describing: ExamAndCourseTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
