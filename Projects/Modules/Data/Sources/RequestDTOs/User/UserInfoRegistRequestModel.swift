//
//  UserInfoRegistRequestModel.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/25/25.
//

import Foundation

public struct UserInfoRegistReqeustModel: Encodable {
    public let nickname: String
    public let birthday: String?
    public let gender: String?
    
    public init(nickname: String, birthday: String?, gender: String?) {
        self.nickname = nickname
        self.birthday = birthday
        self.gender = gender
    }
}
