//
//  UserInfoRegistRequestModel.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/25/25.
//

import Foundation

struct UserInfoRegistReqeustModel: Encodable {
    let nickname: String
    let birthday: String? 
    let gender: String?
}
