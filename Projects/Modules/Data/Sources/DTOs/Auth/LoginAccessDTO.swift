//
//  LoginAccessDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/21/25.
//

import Foundation
import Domain

public struct LoginAccessDTO: DTO {
    public let accessToken, refreshToken: String
    public let links: DeepLinkDTO?

    enum CodingKeys: String, CodingKey {
        case links = "_links"
        case accessToken, refreshToken
    }
}
