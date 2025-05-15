//
//  AppleAccessDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/30/25.
//

import Foundation

struct AppleAccessDTO: DTO {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String
    let id_token: String
}
