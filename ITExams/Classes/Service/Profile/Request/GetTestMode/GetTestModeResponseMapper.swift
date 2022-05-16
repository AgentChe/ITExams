//
//  GetTestModeResponseMapper.swift
//  FNP
//
//  Created by Andrey Chernyshev on 09.07.2021.
//

final class GetTestModeResponseMapper {
    static func map(from response: Any) -> TestMode? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let code = data["test_mode"] as? Int
        else {
            return nil
        }
        
        return TestMode(code: code)
    }
}
