//
//  LoginAccessDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/21/25.
//

import Foundation

struct LoginAccessDTO: DTO {
    let accessToken, refreshToken: String
    let links: DeepLinkDTO?

    enum CodingKeys: String, CodingKey {
        case links = "_links"
        case accessToken, refreshToken
    }
}
