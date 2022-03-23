//
//  PaygateViewControllerDelegate.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.03.2022.
//

enum PaygateViewControllerResult {
    case bied, restored, cancelled
}

protocol PaygateViewControllerDelegate: AnyObject {
    func paygateDidClosed(with result: PaygateViewControllerResult)
}
