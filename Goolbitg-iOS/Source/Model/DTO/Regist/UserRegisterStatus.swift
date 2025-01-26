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
    case onBoarding1 = 0
    case onBoarding2
    case onBoarding3
    case onBoarding4
    case registEnd
}
