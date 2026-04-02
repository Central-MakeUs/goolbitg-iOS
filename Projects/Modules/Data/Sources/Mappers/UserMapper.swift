//
//  UserMapper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import ComposableArchitecture
import Utils

public final class UserMapper: Sendable {
    
    /// 유형 결과 Mapping
    /// - Parameter model: 유저 전체 모델
    /// - Returns: 결과 뷰에 쓸 모델
    public func resultHabitMapping(model: UserInfoDTO) -> UserHabitResultEntity {
        var url: URL? = nil
        if let imageURLString = model.spendingType.imageURL{
            url = URL(string: imageURLString)
        }
        var shareImageURL: URL? = nil
        
        if let shareImageUrl = model.spendingType.onboardingResultUrl {
            shareImageURL = URL(string: shareImageUrl)
        }
        
        return UserHabitResultEntity(
            topTitle: model.nickname + "님은\n" + model.spendingType.title + " 유형입니다",
            stepTitle: String(model.spendingType.id) + "단계 굴비",
            nameTitle: model.spendingType.title,
            imageUrl: url,
            shareImageUrl: shareImageURL,
            spendingScore: String(model.spendingHabitScore) + "점",
            sameCount: String(model.spendingType.peopleCount ?? 0) + "명"
        )
    }
    
    public func homeTopViewMapping(dto: UserWeeklyStatusDTO) -> HomeUserInfoEntity  {
        let savingText = byAmountCase(amount: dto.saving ?? 0)
        return HomeUserInfoEntity(
            nickName: dto.nickname ?? UserDefaultsManager.userNickname,
            saveMoney: dto.saving ?? 0,
            awardText: String(dto.continueCount ?? 0) + "일째 달성중",
            chickenCount: savingText.title
        )
    }
    
    /// 홈 주간 매핑
    /// - Parameter dto: dto
    /// - Returns: [OneWeekDay]
    public func weeklyHomeMapping(dto: UserWeeklyStatusDTO) async -> [OneWeekDay] {
        let currentWeek = DateManager.shared.fetchWeekDate()
        
        let mapping = await (currentWeek.enumerated()).asyncMap { index, item in
            var weekStatus = false
            if let status = dto.weeklyStatus[safe: index] {
                let success = status.achievedChallenges ?? 0
                let will = status.totalChallenges ?? 0
                
                if success != 0, will != 0, success == will {
                    weekStatus = true
                }
            }
            
            return OneWeekDay(
                date: item,
                weekState: weekStatus
            )
        }
        return mapping
    }
    
    /// 마이 페이지 매핑 함수
    /// - Parameter model: User DTO
    /// - Returns: MyPage Entity
    public func myPageUserMapping(model: UserInfoDTO) -> UserMyPageEntity {
        
        var nextGold = (model.spendingType.goal ?? 0).toString
        nextGold = GBNumberForMatter.shared.changeForCommaNumber(nextGold)
        
        return UserMyPageEntity(
            nickname: model.nickname,
            typeDetail: model.spendingType.title,
            spandingScore: String(model.spendingHabitScore) + "점",
            totalChallengeCount: String(model.challengeCount),
            shareImageUrl: URL(string: model.spendingType.onboardingResultUrl ?? ""),
            writeCount: String(model.postCount),
            nextGoolbTitle: "다음 굴비까지 " + nextGold + "원 남았어요",
            nextGoolBPercent: model.achievementGuage / Double(model.spendingType.goal ?? 0),
            userID: model.id,
            userTypeImageUrl: model.spendingType.profileUrl
        )
    }

    public func habitChartsAnalysisMapping(model: AnalysisAllDTO) -> HabitChartsAnalysisEntity {
        let summary = model.summary
        let completion = model.completionAnalysis
        let category = model.categoryAnalysis
        let indvGroup = model.indvGroupAnalysis
        let buyOrNot = model.buyOrNotAnalysis

        let userHabitInfo = UserHabitInfoEntity(
            userName: summary.username,
            userType: summary.spendingType,
            upperPercent: summary.percantage,
            imageURL: summary.imageUrl
        )

        let previousCount = max(completion.prev, 0)
        let currentCount = max(completion.current, 0)
        let recommendationCount = max(completion.recommandation, 0)

        let recentMaxCount = max(previousCount, currentCount, recommendationCount, 1)
        let recentMonthlyData: [RecentChallengeWeeklyEntity] = [
            .init(title: "지난주", count: previousCount, isRecommend: false, barStyle: .grey),
            .init(title: "이번주", count: currentCount, isRecommend: false, barStyle: .mainColor),
            .init(title: "다음주", count: recommendationCount, isRecommend: true, barStyle: .dotStyleForRecommend)
        ]

        let categoryInfos = category.scores.map {
            CategoryInfo(
                name: $0.catName,
                currentValue: Double(max($0.success, 0)),
                maxValue: Double(max($0.total, 1))
            )
        }
        let topCategory = category.scores.max(by: { $0.success < $1.success })?.catName ?? "기타"
        let categoryInfo = CategoryCompareEntity(message: category.message, topCategory: topCategory, allCategories: categoryInfos)

        let individualSuccessRate = indvGroup.indvScore
        let groupSuccessRate = indvGroup.groupScore
        

        let buyScore = max(buyOrNot.buyScore, 0)
        let notScore = max(buyOrNot.notScore, 0)
        let totalScore = max(buyScore + notScore, 1)
        let buyRate = (buyScore / totalScore) * 100
        let notRate = (notScore / totalScore) * 100
        let buyOrNotDatas: [BuyOrNotChartDataEntity] = [
            .init(goodOrBad: true, rate: buyRate),
            .init(goodOrBad: false, rate: notRate)
        ]

        return HabitChartsAnalysisEntity(
            userHabitInfo: userHabitInfo,
            recentMessage: completion.message,
            recentMaxCount: recentMaxCount,
            recentMonthlyData: recentMonthlyData,
            categoryInfo: categoryInfo,
            individualSuccessRate: individualSuccessRate,
            groupSuccessRate: groupSuccessRate,
            individualGroupMessage: indvGroup.message,
            buyOrNotMessage: buyOrNot.message,
            buyOrNotDatas: buyOrNotDatas
        )
    }
}

extension UserMapper {
    private func byAmountCase(amount: Int) -> AmountCase {
        if amount >= 500000 {
            return .playStation
        }
        else if amount >= 400000 {
            return .dryCleaning
        }
        else if amount >= 300000 {
            return .appleWatch
        }
        else if amount >= 200000 {
            return .airPods
        }
        else if amount >= 100000 {
            return .newWorld
        }
        else if amount >= 50000 {
            return .koreanBeef
        }
        else if amount >= 40000 {
            return .stanly
        }
        else if amount >= 30000 {
            return .hallCake
        }
        else if amount >= 20000 {
            return .chicken
        }
        else if amount >= 10000 {
            return .movie
        }
        else if amount >= 5000 {
            return .taxi
        }
        else if amount >= 2000 {
            return .coffee
        }
        else {
            return .none
        }
    }
}

extension UserMapper: DependencyKey {
    public static let liveValue: UserMapper = UserMapper()
}

extension DependencyValues {
    public var userMapper: UserMapper {
        get { self[UserMapper.self] }
        set { self[UserMapper.self] = newValue }
    }
}
