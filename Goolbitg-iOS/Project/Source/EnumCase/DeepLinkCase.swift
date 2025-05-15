//
//  DeepLinkCase.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/22/25.
//

import Foundation

enum DeepLinkCase {
    case userInfo
    
    init?(urlString: String) {
        switch urlString {
        case SecretKeys.baseURL + "/v1" + "/users/me/info":
            self = .userInfo
        default:
            return nil
        }
    }
    
    init?(url: URL) {
        switch url.absoluteString {
        case SecretKeys.baseURL + "/v1" + "/users/me/info":
            self = .userInfo
        default:
            return nil
        }
    }
}
