//
//  AuthRegisterRequestModel.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation

struct AuthRegisterRequestModel: Encodable {
    /// ex) KAKAO - APPLE
    let type: String
    let idToken: String
}
