//
//  CheckPayload.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/25/25.
//

import Foundation

struct CheckPayload: Encodable {
    let checks: [String: Bool]
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCheckListCodingKeys.self)
        for (key, value) in checks {
            guard let codingKey = DynamicCheckListCodingKeys(stringValue: key) else {
                continue
            }
            try container.encode(value, forKey: codingKey)
        }
    }
}

struct DynamicCheckListCodingKeys: CodingKey {
    var stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? { return nil }
    
    init?(intValue: Int) { return nil }
}
