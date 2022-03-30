//
//  GetPlanRequest.swift
//  ITExams
//
//  Created by Андрей Чернышев on 30.03.2022.
//

import Alamofire

struct GetPlanRequest: APIRequestBody {
    let userToken: String
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/plan/list"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken
        ]
    }
}
