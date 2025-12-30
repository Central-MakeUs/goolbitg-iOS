//
//  APIErrorEntity.swift
//  Network
//
//  Created by Jae hyung Kim on 5/21/25.
//

import Foundation
import Domain

public enum APIErrorEntity: Int, Entity {
    
    // 일반 오류
    /// 입력 오류
    case inputError = 1001

    // 인증 & 인가 오류
    /// 유효하지 않은 토큰
    case invalidToken = 2001
    /// 토큰 만료
    case tokenExpiration = 2002 // 이때 재로그인
    /// 인증 정보 없음
    case noCredentials = 2003 // 이때 재로그인
    /// 접근 권한 없음
    case noAccess = 2004 // 이때 재로그인
    /// 로그아웃 되버렷
    case logoutCase = 2005 // 이때 재로그인

    // 유저 오류
    /// 이미 등록된 회원
    case alreadyMember = 3001
    /// 등록되지 않은 회원
    case notRegisteredMember = 3002
    /// 필수 회원정보 입력이 완료되지 않음
    case incompleteMemberInfo = 3003

    // 작심삼일 챌린지 오류
    /// 이미 참여중인 챌린지
    case alreadyParticipatingChallenge = 4001
    /// 참여중이지 않은 챌린지
    case notParticipatingChallenge = 4002
    /// 챌린지 이름 중복
    case duplicateChallengeName = 4003
    /// 존재하지 않는 챌린지
    case challengeNotFound = 4004
    /// 이미 완료한 챌린지
    case challengeAlreadyCompleted = 4005
    
    // Passwd 불일치 에러
    case passwordError = 4007

    // 살까말까 오류
    /// 포스트 등록 한도 초과
    case postLimitExceeded = 5001
    /// 존재하지 않는 포스트
    case postNotFound = 5002
    /// 이미 신고한 포스트
    case alreadyReportedPost = 5004

    // 알림 오류
    /// 존재하지 않는 알림
    case notificationNotFound = 6001
    /// 이미 읽은 알림
    case notificationAlreadyRead = 6002
    
    
    public static func getSelf(code: Int) -> APIErrorEntity? {
        return APIErrorEntity(rawValue: code)
    }
    
    public var errorMessage: String {
        switch self {
        case .inputError:
            return "입력 오류가 발생했습니다."
        case .invalidToken:
            return "유효하지 않은 토큰입니다."
        case .tokenExpiration:
            return "토큰이 만료되었습니다."
        case .noCredentials:
            return "토큰이 필요합니다."
        case .noAccess:
            return "접근이 제한되었습니다."
        case .logoutCase:
            return "로그아웃 되었습니다."
        case .alreadyMember:
            return "이미 회원입니다."
        case .notRegisteredMember:
            return "회원이 아닙니다."
        case .incompleteMemberInfo:
            return "회원정보가 불완전합니다."
        case .alreadyParticipatingChallenge:
            return "이미 참여한 챌린지입니다."
        case .notParticipatingChallenge:
            return "참여하지 않은 챌린지입니다."
        case .duplicateChallengeName:
            return "중복된 챌린지 이름입니다."
        case .challengeNotFound:
            return "챌린지가 존재하지 않습니다."
        case .challengeAlreadyCompleted:
            return "챌린지가 이미 완료되었습니다."
        case .passwordError:
            return "비밀번호가 틀렸습니다."
        case .postLimitExceeded:
            return "포스트가 작성할 수 있는 한계를 초과하였습니다."
        case .postNotFound:
            return "포스트가 존재하지 않습니다."
        case .alreadyReportedPost:
            return "이미 신고한 포스트입니다."
        case .notificationNotFound:
            return "알림이 존재하지 않습니다."
        case .notificationAlreadyRead:
            return "알림을 이미 읽었습니다."
        }
    }
}
