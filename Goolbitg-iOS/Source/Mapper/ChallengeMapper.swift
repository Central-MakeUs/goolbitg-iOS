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
        let url = URL(string: dto.imageURL)
        // MARK: SubTitle 이 존재하지 않음
        let result = GBNumberForMatter.shared.changeForCommaNumber(String(dto.reward ?? 0))
        
        return ChallengeEntity(
            id: String(dto.id),
            imageUrl: url,
            title: dto.title,
            subTitle: result + "원 절약 가능",
            reward: dto.reward?.toString,
            participantCount: dto.participantCount.toString,
            avgAchiveRatio: dto.avgAchieveRatio.toString,
            maxAchiveDays: dto.maxAchieveDays
        )
    }
    
    func toEntity(dto: ChallengeRecordDTO) -> ChallengeEntity {
        
        return ChallengeEntity(
            id: String(dto.challenge.id),
            imageUrl: URL(string:dto.challenge.imageURL),
            title: dto.challenge.title,
            subTitle: String(dto.challenge.maxAchieveDays) + "일째 진행중",
            reward: String(dto.challenge.reward ?? 0),
            participantCount: String(dto.challenge.participantCount),
            avgAchiveRatio: String(dto.challenge.avgAchieveRatio),
            maxAchiveDays: dto.challenge.maxAchieveDays
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
