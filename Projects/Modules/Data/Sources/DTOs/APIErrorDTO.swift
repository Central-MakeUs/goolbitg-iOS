//
//  APIErrorDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation
import Domain

/// 굴비 API 에러 모델
public struct APIErrorDTO: DTO {
    public let code: Int
    public let message: String
}
