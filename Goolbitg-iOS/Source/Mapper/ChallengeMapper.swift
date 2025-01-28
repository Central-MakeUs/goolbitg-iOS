//
//  ChallengeMapper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import ComposableArchitecture

final class ChallengeMapper: Sendable {
    
    func toEntity(dto: ChallengeListDTO) async -> [ChallengeEntity] {
        return await dto.items.asyncMap {
            toEntity(dto: $0)
        }
    }
    
    func toEntity(dto: ChallengeListElementDTO) -> ChallengeEntity {
        let url = URL(string: dto.imageURL)
        // MARK: SubTitle 이 존재하지 않음
        return ChallengeEntity(
            id: String(dto.id),
            imageUrl: url,
            title: dto.title,
            subTitle: nil,
            reward: dto.reward?.toString,
            participantCount: dto.participantCount.toString,
            avgAchiveRatio: dto.avgAchiveRatio.toString,
            maxAchiveDays: dto.maxAchiveDays
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
