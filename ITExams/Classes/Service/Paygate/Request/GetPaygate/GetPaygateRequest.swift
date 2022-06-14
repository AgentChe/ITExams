//
//  GetPaygateRequest.swift
//  ITExams
//
//  Created by Андрей Чернышев on 14.06.2022.
//

import Alamofire

struct GetPaygateRequest: APIRequestBody {
    let userToken: String
    let userProducts: [String]
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/payments/paygate"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "platform": 1,
            "used_products": userProducts
        ]
    }
}
