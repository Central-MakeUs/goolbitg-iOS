//
//  AccessTokenDTO.swift
//  DTOs
//
//  Created by Jae hyung Kim on 5/21/25.
//

import Foundation
import Domain

public struct AccessTokenDTO: DTO {
    public let accessToken: String
    public let refreshToken: String
}
