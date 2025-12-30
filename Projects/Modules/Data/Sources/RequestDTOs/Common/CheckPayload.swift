//
//  CheckPayload.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/25/25.
//

import Foundation

public struct CheckPayload: Encodable {
    public let checks: [String: Bool]
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCheckListCodingKeys.self)
        for (key, value) in checks {
            guard let codingKey = DynamicCheckListCodingKeys(stringValue: key) else {
                continue
            }
            try container.encode(value, forKey: codingKey)
        }
    }
    
    public init(checks: [String : Bool]) {
        self.checks = checks
    }
}

public struct DynamicCheckListCodingKeys: CodingKey {
    public var stringValue: String
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public var intValue: Int? { return nil }
    
    public init?(intValue: Int) { return nil }
}
