//
//  PaygateManager.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.03.2022.
//

import RxSwift
import SwiftyStoreKit

final class PaygateManager {}

// MARK: Obtain prices
extension PaygateManager {
    func obtainPrices(for ids: [String]) -> Single<[ProductPrice]> {
        Single<[ProductPrice]>.create { event in
            SwiftyStoreKit.retrieveProductsInfo(Set(ids)) { results in
                let prices = results.retrievedProducts.map { product -> ProductPrice in
                    ProductPrice(product: product)
                }
                
                event(.success(prices))
            }
            
            return Disposables.create()
        }
    }
}
