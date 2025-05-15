//
//  APIErrorDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation

/// 굴비 API 에러 모델
struct APIErrorDTO: DTO {
    let code: Int
    let message: String
}
