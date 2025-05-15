//
//  ChallengeEmptyCase.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/9/25.
//

import Foundation

enum ChallengeEmptyCase: Equatable {
    case beforeIngEmpty
    case todayButIngEmpty
    case todaySuccessEmpty
    
    var title: String {
        switch self {
        case .beforeIngEmpty:
            return "진행된 챌린지가 없어요!"
        case .todayButIngEmpty:
            return "진행 할 챌린지가 없어요\n우측 상단 +를 눌러 챌린지를 추가해주세요"
        case .todaySuccessEmpty:
            return "진행 완료 된 챌린지가 없어요!"
        }
    }
}
