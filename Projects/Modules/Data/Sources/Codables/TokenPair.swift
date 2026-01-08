//
//  TokenPair.swift
//  Data
//
//  Created by Jae hyung Kim on 1/9/26.
//

import Foundation

public struct TokenPair: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
