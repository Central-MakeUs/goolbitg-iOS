//
//  UserInfoDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import Domain

// MARK: - UserInfoDTO
public struct UserInfoDTO: DTO, Equatable {
    /// 사용자 고유 ID
    public let id: String
    /// 사용자 닉네임
    public let nickname: String            // 사용자 닉네임
    /// 생년월일 (YYYY-MM-DD 형식)
    public let birthday: String?            // 생년월일 (YYYY-MM-DD 형식)
    /// 성별 ("MALE" 또는 "FEMALE")
    public let gender: String?              // 성별 ("MALE" 또는 "FEMALE")
    
    // 사용자의 특정 체크 여부
    public let check1: Bool
    public let check2: Bool
    public let check3: Bool
    public let check4: Bool
    public let check5: Bool
    public let check6: Bool
    
    /// 월 평균 소득 (단위: 원)/
    public let avgIncomePerMonth: Int      // 월 평균 소득 (단위: 원)
    /// 월 평균 소비 금액 (단위: 원)/
    public let avgSpendingPerMonth: Int    // 월 평균 소비 금액 (단위: 원)
    
    /// 사용자가 가장 자주 소비하는 요일 (예: "FRIDAY")
    public let primeUseDay: String?         // 사용자가 가장 자주 소비하는 요일 (예: "FRIDAY")
    /// 사용자가 가장 자주 소비하는 시간 (예: "20:00:00")
    public let primeUseTime: String?        // 사용자가 가장 자주 소비하는 시간 (예: "20:00:00")
    /// 사용자의 소비 습관 점수 (0~100 사이의 점수)/
    public let spendingHabitScore: Int     // 사용자의 소비 습관 점수 (0~100 사이의 점수)
    
    /// 사용자의 소비 유형 정보 (타입 ID, 제목, 이미지 URL 포함)
    public let spendingType: SpendingTypeDTO // 사용자의 소비 유형 정보 (타입 ID, 제목, 이미지 URL 포함)
    /// 사용자가 참여한 챌린지 개수
    public let challengeCount: Int         // 사용자가 참여한 챌린지 개수
    /// 사용자가 작성한 게시물 개수
    public let postCount: Int              // 사용자가 작성한 게시물 개수
    /// 사용자의 목표 달성률 (예: 37.2%)
    public let achievementGuage: Double     // 사용자의 목표 달성률 (예: 37.2%)
    
    
    public init(
        id: String,
        nickname: String,
        birthday: String?,
        gender: String?,
        check1: Bool,
        check2: Bool,
        check3: Bool,
        check4: Bool,
        check5: Bool,
        check6: Bool,
        avgIncomePerMonth: Int,
        avgSpendingPerMonth: Int,
        primeUseDay: String?,
        primeUseTime: String?,
        spendingHabitScore: Int,
        spendingType: SpendingTypeDTO,
        challengeCount: Int,
        postCount: Int,
        achievementGuage: Double
    ) {
        self.id = id
        self.nickname = nickname
        self.birthday = birthday
        self.gender = gender
        self.check1 = check1
        self.check2 = check2
        self.check3 = check3
        self.check4 = check4
        self.check5 = check5
        self.check6 = check6
        self.avgIncomePerMonth = avgIncomePerMonth
        self.avgSpendingPerMonth = avgSpendingPerMonth
        self.primeUseDay = primeUseDay
        self.primeUseTime = primeUseTime
        self.spendingHabitScore = spendingHabitScore
        self.spendingType = spendingType
        self.challengeCount = challengeCount
        self.postCount = postCount
        self.achievementGuage = achievementGuage
    }
}

