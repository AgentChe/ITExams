//
//  GetPlanTestRequest.swift
//  ITExams
//
//  Created by Андрей Чернышев on 09.06.2022.
//

import Alamofire

struct GetPlanTestRequest: APIRequestBody {
    let userToken: String
    let testId: Int
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/plan/test"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
         [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "id": testId
        ]
    }
}
