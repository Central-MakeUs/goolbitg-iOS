//
//  UserNickNameCheckRequestModel.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/25/25.
//

import Foundation

public struct UserNickNameCheckReqeustModel: Encodable {
    public let nickname: String
    
    public init(nickname: String) {
        self.nickname = nickname
    }
}
