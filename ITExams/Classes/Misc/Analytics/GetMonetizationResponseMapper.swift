//
//  GetMonetizationResponse.swift
//  ITExams
//
//  Created by Андрей Чернышев on 29.03.2022.
//

final class GetMonetizationResponseMapper {
    static func map(from response: Any) -> Monetization? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let mode = data["mode"] as? Int
        else {
            return nil
        }

        switch mode {
        case 1:
            // без оплаты/подписки доступен бесплатный контент, пользователя нужно запустить в приложение
            return .suggest
        case 2:
            // без оплаты/подписки невозможно пройти далее онбординга
            return .block
        default:
            return nil
        }
    }
}
