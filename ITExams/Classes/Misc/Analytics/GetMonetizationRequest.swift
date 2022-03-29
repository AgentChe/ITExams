//
//  GetMonetizationRequest.swift
//  ITExams
//
//  Created by Андрей Чернышев on 29.03.2022.
//

import Alamofire

struct GetMonetizationRequest: APIRequestBody {
    private let userToken: String?
    private let version: String
    private let appAnonymousId: String
    
    init(userToken: String? = nil,
         version: String,
         appAnonymousId: String) {
        self.userToken = userToken
        self.version = version
        self.appAnonymousId = appAnonymousId
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/monetization"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        var params: Parameters = [
            "_api_key": GlobalDefinitions.apiKey,
            "anonymous_id": appAnonymousId,
            "version": version
        ]
        
        if let userToken = self.userToken {
            params["_user_token"] = userToken
        }
        
        return params
    }
}
