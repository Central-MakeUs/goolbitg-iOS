//
//  UserMapper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import ComposableArchitecture

final class UserMapper: Sendable {
    
    /// 유형 결과 Mapping
    /// - Parameter model: 유저 전체 모델
    /// - Returns: 결과 뷰에 쓸 모델
    func resultHabitMapping(model: UserInfoDTO) -> UserHabitResultEntity {
        var url: URL? = nil
        if let imageURLString = model.spendingType.imageURL{
            url = URL(string: imageURLString)
        }
        
        return UserHabitResultEntity(
            topTitle: model.nickname + "님은\n" + model.spendingType.title + " 유형입니다",
            stepTitle: String(model.spendingType.id) + "단계 굴비",
            nameTitle: model.spendingType.title,
            imageUrl: url,
            spendingScore: String(model.spendingHabitScore) + "점",
            sameCount: String(model.spendingType.peopleCount ?? 0) + "명"
        )
    }
    
    func homeTopViewMapping(dto: UserWeeklyStatusDTO) -> HomeUserInfoEntity  {
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
    func weeklyHomeMapping(dto: UserWeeklyStatusDTO) async -> [OneWeekDay] {
        let currentWeek = DateManager.shared.fetchWeekDate()
        
        let mapping = await (currentWeek.enumerated()).asyncMap { index, item in
            
            var weekStatus: ChallengeStatusCase = .none
            
            if let status = dto.weekStatus[safe: index] {
                weekStatus = ChallengeStatusCase.getSelf(initValue: status.rawValue)
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
    func myPageUserMapping(model: UserInfoDTO) -> UserMyPageEntity {
        
        var nextGold = (model.spendingType.goal ?? 0).toString
        nextGold = GBNumberForMatter.shared.changeForCommaNumber(nextGold)
        
        return UserMyPageEntity(
            nickname: model.nickname,
            typeDetail: model.spendingType.title,
            spandingScore: String(model.spendingHabitScore) + "점",
            totalChallengeCount: String(model.challengeCount),
            writeCount: String(model.postCount),
            nextGoolbTitle: "다음 굴비까지 " + nextGold + "원 남았어요",
            nextGoolBPercent: 0,
            userID: model.id
        )
    }
}

extension UserMapper {
    private func byAmountCase(amount: Int) -> AmountCase {
        if amount >= 100000 {
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
        else {
            return .none
        }
    }
}

extension UserMapper: DependencyKey {
    static let liveValue: UserMapper = UserMapper()
}

extension DependencyValues {
    var userMapper: UserMapper {
        get { self[UserMapper.self] }
        set { self[UserMapper.self] = newValue }
    }
}

