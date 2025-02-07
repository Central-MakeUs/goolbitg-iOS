//
//  ChallengeMapper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import ComposableArchitecture

final class ChallengeMapper: Sendable {
    
    func toEntity(dtos: [ChallengeListElementDTO]) async -> [ChallengeEntity] {
        return await dtos.asyncMap {
            toEntity(dto: $0)
        }
    }
    
    func toEntity(dtos: [ChallengeRecordDTO]) async -> [ChallengeEntity] {
        return await dtos.asyncMap {
            toEntity(dto: $0)
        }
    }
    
    func toEntity(dto: ChallengeListElementDTO) -> ChallengeEntity {
        let url = URL(string: dto.imageUrlSmall ?? "")
        let urlLarge = URL(string: dto.imageUrlLarge ?? "")
        // MARK: SubTitle 이 존재하지 않음
        let result = GBNumberForMatter.shared.changeForCommaNumber(String(dto.reward ?? 0))
        
        return ChallengeEntity(
            id: String(dto.id),
            imageUrl: url,
            imageUrlLarge: urlLarge,
            title: dto.title,
            subTitle: result + "원 절약 가능",
            reward: dto.reward?.toString,
            participantCount: dto.participantCount.toString,
            avgAchiveRatio: dto.avgAchieveRatio.toString,
            maxAchiveDays: dto.maxAchieveDays,
            status: nil
        )
    }
    
    func toEntity(dto: ChallengeRecordDTO) -> ChallengeEntity {
        
        return ChallengeEntity(
            id: String(dto.challenge.id),
            imageUrl: URL(string:dto.challenge.imageUrlSmall ?? ""),
            imageUrlLarge: URL(string: dto.challenge.imageUrlLarge ?? ""),
            title: dto.challenge.title,
            subTitle: String(dto.challenge.maxAchieveDays) + "일째 진행중",
            reward: String(dto.challenge.reward ?? 0),
            participantCount: String(dto.challenge.participantCount),
            avgAchiveRatio: String(dto.challenge.avgAchieveRatio),
            maxAchiveDays: dto.challenge.maxAchieveDays,
            status: ChallengeStatusCase.getSelf(initValue: dto.status)
        )
    }
    
    func toEntityConfigurationForHome(dtos: [ChallengeRecordDTO]) async -> [CommonCheckListConfiguration] {
        return await dtos.asyncMap {
            return toEntityConfigurationForHome(dto: $0)
        }
    }
    
    func toEntityConfigurationForHome(dto: ChallengeRecordDTO) -> CommonCheckListConfiguration {
        return CommonCheckListConfiguration(
            id: String(dto.challenge.id),
            currentState: false,
            checkListTitle: dto.challenge.title,
            subText: "+" + String(dto.challenge.reward ?? 0)
        )
    }
    
    func toEntityTripple(dto: ChallengeTrippleDTO) -> ChallengeTrippleEntity {
        
        let dayText = String(dto.duration) + "일째, 열심히 진행중입니다"
        
        let currentIndex = dto.location - 1
        
        let dayStatus = Array([dto.check1, dto.check2, dto.check3].enumerated())
            .map { index, item -> ChallengeStatusCase in
                var serverResponse = ChallengeStatusCase.getSelf(initValue: item.rawValue)
                
                if currentIndex < index, item == .wait {
                    serverResponse = .none
                }
                return serverResponse
            }
            
        let withMe = "현재 \(dto.challenge.participantCount)명이 챌린지 진행하고 있어요!"
        let weekAvgText = "일주일 기준 평균 \(dto.challenge.avgAchieveRatio)% 달성했어요!"
        let longTimeText = "가장 오래는 \(dto.challenge.maxAchieveDays)일동안 진행했어요!"
        
        return ChallengeTrippleEntity(
            challengeTitle: dto.challenge.title,
            imageURL: URL(string:dto.challenge.imageUrlLarge ?? ""),
            userName: UserDefaultsManager.userNickname,
            dayCountWithStatus: dayText,
            challengeStatus: dayStatus,
            currentPeopleChallengeState: withMe,
            weekAvgText: weekAvgText,
            fullDays: longTimeText,
            cancelBool: dto.canceled ?? true
        )
    }
    
    func toMappingWeek(weekDays: [WeekDay], currentWeek: UserWeeklyStatusDTO) async -> [WeekDay] {
        let list = currentWeek.weeklyStatus
        return await Array(weekDays.enumerated()).asyncMap { index, item in
            return toMappingWeek(weekDay: item, currentWeek: list[index])
        }
    }
    
    func toMappingWeek(weekDay: WeekDay, currentWeek: UserWeeklyStatusElementDTO) -> WeekDay {
        
        let total = currentWeek.totalChallenges ?? 0
        let current = currentWeek.achievedChallenges ?? 0
        var active = true
        
        let percent: Double
        if total == 0 {
            percent = 0.0
            active = false
        } else {
            percent = Double(current) / Double(total)
        }
        
        return WeekDay(
            date: weekDay.date,
            active: active,
            isSelected: false,
            percent: percent
        )
    }
    
    
}

extension ChallengeMapper: DependencyKey {
    static let liveValue: ChallengeMapper = ChallengeMapper()
}

extension DependencyValues {
    var challengeMapper: ChallengeMapper {
        get { self[ChallengeMapper.self] }
        set { self[ChallengeMapper.self] = newValue }
    }
}
