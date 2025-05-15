//
//  RevokeRequestDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/5/25.
//

import Foundation

struct RevokeRequestDTO: Encodable {
    let reason: String
    let authorizationCode: String?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reason, forKey: .reason)
        
        if let authorizationCode = authorizationCode {
            try container.encode(authorizationCode, forKey: .authorizationCode)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case reason
        case authorizationCode
    }
}
