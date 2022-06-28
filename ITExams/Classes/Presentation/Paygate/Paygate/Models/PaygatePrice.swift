//
//  PaygatePrice.swift
//  ITExams
//
//  Created by Андрей Чернышев on 23.03.2022.
//

struct PaygatePrice {
    enum Product {
        case lifetime, monthlyTrial, monthly
    }
    
    let product: Product
    let price: ProductPrice
}
