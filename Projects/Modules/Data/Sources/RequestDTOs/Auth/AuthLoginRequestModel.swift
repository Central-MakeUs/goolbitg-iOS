//
//  AuthLoginRequestModel.swift
//  RequestDTOs
//
//  Created by Jae hyung Kim on 5/21/25.
//

import Foundation

/// Login
public struct AuthLoginRequestModel: Encodable {
    public let type: String
    public let idToken: String
    
    public init(type: String, idToken: String) {
        self.type = type
        self.idToken = idToken
    }
}
