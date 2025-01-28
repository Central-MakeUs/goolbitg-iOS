//
//  UserInfoDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation

// MARK: - UserInfoDTO
struct UserInfoDTO: DTO, Equatable {
    /// 사용자 고유 ID
    let id: String
    /// 사용자 닉네임
    let nickname: String            // 사용자 닉네임
    /// 생년월일 (YYYY-MM-DD 형식)
    let birthday: String            // 생년월일 (YYYY-MM-DD 형식)
    /// 성별 ("MALE" 또는 "FEMALE")
    let gender: String              // 성별 ("MALE" 또는 "FEMALE")
    
    // 사용자의 특정 체크 여부
    let check1: Bool
    let check2: Bool
    let check3: Bool
    let check4: Bool
    let check5: Bool
    let check6: Bool
    
    /// 월 평균 소득 (단위: 원)/
    let avgIncomePerMonth: Int      // 월 평균 소득 (단위: 원)
    /// 월 평균 소비 금액 (단위: 원)/
    let avgSpendingPerMonth: Int    // 월 평균 소비 금액 (단위: 원)
    
    /// 사용자가 가장 자주 소비하는 요일 (예: "FRIDAY")
    let primeUseDay: String?         // 사용자가 가장 자주 소비하는 요일 (예: "FRIDAY")
    /// 사용자가 가장 자주 소비하는 시간 (예: "20:00:00")
    let primeUseTime: String?        // 사용자가 가장 자주 소비하는 시간 (예: "20:00:00")
    /// 사용자의 소비 습관 점수 (0~100 사이의 점수)/
    let spendingHabitScore: Int     // 사용자의 소비 습관 점수 (0~100 사이의 점수)
    
    /// 사용자의 소비 유형 정보 (타입 ID, 제목, 이미지 URL 포함)
    let spendingType: SpendingTypeDTO // 사용자의 소비 유형 정보 (타입 ID, 제목, 이미지 URL 포함)
    /// 사용자가 참여한 챌린지 개수
    let challengeCount: Int         // 사용자가 참여한 챌린지 개수
    /// 사용자가 작성한 게시물 개수
    let postCount: Int              // 사용자가 작성한 게시물 개수
    /// 사용자의 목표 달성률 (예: 37.2%)
    let achivementGuage: Double     // 사용자의 목표 달성률 (예: 37.2%)
}

