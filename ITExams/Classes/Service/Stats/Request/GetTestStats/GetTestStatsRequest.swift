//
//  GetTestStatsRequest.swift
//  ITExams
//
//  Created by Андрей Чернышев on 08.06.2022.
//

import Alamofire

struct GetTestStatsRequest: APIRequestBody {
    let userToken: String
    let userTestId: Int
    let peek: Bool
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/tests/stats"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "user_test_id": userTestId,
            "peek": peek
        ]
    }
}
