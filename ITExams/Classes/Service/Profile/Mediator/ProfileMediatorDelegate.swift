//
//  ProfileMediatorDelegate.swift
//  ITExams
//
//  Created by Андрей Чернышев on 29.03.2022.
//

protocol ProfileMediatorDelegate: AnyObject {
    func didChanged(testMode: TestMode)
}
