//
//  GetReviewResponse.swift
//  ITExams
//
//  Created by Андрей Чернышев on 06.06.2022.
//

final class GetReviewResponse {
    static func map(from response: Any) -> [Review] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [[String: Any]]
        else {
            return []
        }
    
        return data.compactMap { reviewJSON -> Review? in
            guard
                let questionJSON = reviewJSON["question"] as? [String: Any],
                let question = QuestionMapper.map(from: questionJSON),
                let isCorrectly = reviewJSON["correctly_answered"] as? Bool,
                let userAnswersIds = reviewJSON["user_answers"] as? [Int]
            else {
                return nil
            }
            
            return Review(question: question,
                          isCorrectly: isCorrectly,
                          userAnswersIds: userAnswersIds)
        }
    }
}
