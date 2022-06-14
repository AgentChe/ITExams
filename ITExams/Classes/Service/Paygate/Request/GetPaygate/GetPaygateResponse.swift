//
//  GetPaygateResponse.swift
//  ITExams
//
//  Created by Андрей Чернышев on 14.06.2022.
//

final class GetPaygateResponse {
    static func map(response: Any) -> Paygate? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let questionsCount = data["question_count"] as? Int
        else {
            return nil
        }
        
        return Paygate(questionsCount: questionsCount)
    }
}
