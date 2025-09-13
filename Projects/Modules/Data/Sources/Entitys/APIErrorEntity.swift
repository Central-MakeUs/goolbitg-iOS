//
//  APIErrorEntity.swift
//  Network
//
//  Created by Jae hyung Kim on 5/21/25.
//

import Foundation
import Domain

public enum APIErrorEntity: Int, Entity {
    
    // Passwd 불일치 에러
    case passwordError = 1000
    
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
}
