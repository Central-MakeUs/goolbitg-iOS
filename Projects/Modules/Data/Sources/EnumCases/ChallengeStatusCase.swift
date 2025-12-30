//
//  ChallengeStatusCase.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import Domain

public enum ChallengeStatusCase: Entity, Identifiable {
    /// 생성 시점 -> 진행중
    case wait
    /// 성공적 마무리
    case success
    /// 실패로 마무리
    case fail
    /// 아무 상태도 아닌 경우
    case none
    
    public var requestMode: String {
        switch self {
        case .wait:
            return "WAIT"
        case .success:
            return "SUCCESS"
        case .fail:
            return "FAIL"
        case .none:
            return ""
        }
    }
    
    public static func getSelf(initValue: String) -> ChallengeStatusCase {
        switch initValue {
        case "WAIT":
            return .wait
        case "SUCCESS":
            return .success
        case "FAIL":
            return .fail
        default:
            return .none
        }
    }
    
    public var viewTittle: String {
        switch self {
        case .wait:
            return "진행 중"
        case .fail, .success:
            return "진행 완료"
        case .none:
            return ""
        }
    }
    
    public var buttonTitle: String {
        switch self {
        case .success:
            return "성공"
        case .fail:
            return "실패"
        default:
            return ""
        }
    }
    
    public var id: UUID {
        return UUID()
    }
}
