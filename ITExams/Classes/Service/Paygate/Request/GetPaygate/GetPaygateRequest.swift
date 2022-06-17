//
//  GetPaygateRequest.swift
//  ITExams
//
//  Created by Андрей Чернышев on 14.06.2022.
//

import Alamofire

struct GetPaygateRequest: APIRequestBody {
    let domain: String
    let apiKey: String
    let userToken: String
    let userProducts: [String]
    
    var url: String {
        domain + "/api/payments/paygate"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": apiKey,
            "_user_token": userToken,
            "platform": 1,
            "used_products": userProducts
        ]
    }
}
