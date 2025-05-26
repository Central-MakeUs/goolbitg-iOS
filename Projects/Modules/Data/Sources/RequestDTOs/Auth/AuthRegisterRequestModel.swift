//
//  AuthRegisterRequestModel.swift
//  RequestDTOs
//
//  Created by Jae hyung Kim on 5/21/25.
//

import Foundation

/// SignUp
public struct AuthRegisterRequestModel: Encodable {
    /// ex) KAKAO - APPLE
    public let type: String
    public let idToken: String
    public let authToken: String?
    
    public init(type: String, idToken: String, authToken: String?) {
        self.type = type
        self.idToken = idToken
        self.authToken = authToken
    }
}
