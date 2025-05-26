//
//  NickNameCheckDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/25/25.
//

import Foundation
import Domain

/// 닉네임 중복검사 DTO
public struct NickNameCheckDTO: DTO {
    public let duplicated: Bool
}
