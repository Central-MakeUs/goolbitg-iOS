//
//  ChallengeStatusCase.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation

enum ChallengeStatusCase {
    /// 생성 시점 -> 진행중
    case wait
    /// 성공적 마무리
    case success
    /// 실패로 마무리
    case fail
    
    var requestMode: String {
        switch self {
        case .wait:
            return "WAIT"
        case .success:
            return "SUCCESS"
        case .fail:
            return "FAIL"
        }
    }
    
    var viewTittle: String {
        switch self {
        case .wait:
            return "진행 중"
        case .fail, .success:
            return "진행 완료"
        }
    }
}
