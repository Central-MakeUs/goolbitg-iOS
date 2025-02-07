//
//  RevokeRequestDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/5/25.
//

import Foundation

struct RevokeRequestDTO: Encodable {
    let reason: String
    let authorizationCode: String?
}
