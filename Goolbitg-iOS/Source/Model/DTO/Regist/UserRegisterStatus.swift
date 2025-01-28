//
//  UserRegisterStatus.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/26/25.
//

import Foundation

struct UserRegisterStatus: DTO {
    let status: RegisterStatusCase
    let requiredInfoCompleted: Bool
}

enum RegisterStatusCase: Int, DTO {
    /// 약관
    case onBoarding1 = 0
    /// 사용자 개인정보 등록
    case onBoarding2
    /// 소비 중곧 체크 리스트
    case onBoarding3
    /// 소비습관 정보 등록
    case onBoarding4
    /// 소비날짜 패턴 등록 (필수x)
    case onBoarding5
    /// 진짜 다함
    case registEnd
}
