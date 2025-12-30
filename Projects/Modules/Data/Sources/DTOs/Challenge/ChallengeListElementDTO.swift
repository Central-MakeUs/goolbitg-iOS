//
//  ChallengeListElementDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import Domain

// MARK: - ChallengeListElementDTO
public struct ChallengeListElementDTO: DTO {
    /// 첼린지 아이디
    let id: Int
    /// 챌린지 이름
    let title: String
    /// 챌린지 대표 이미지 URL String
    let imageUrlSmall: String?
    /// 챌린지 대표 이미지 URL String
    let imageUrlLarge: String?
    /// 챌린지 달성시 얻는 금액
    let reward: Int?
    /// 챌린지 참여인원
    let participantCount: Int
    /// 챌린지 평균 달성률
    let avgAchieveRatio: Double
    /// 챌린지 일수 - 가장 오래 진행된 챌린지 일수
    let maxAchieveDays: Int

    enum CodingKeys: String, CodingKey {
        case id, title
        case imageUrlSmall, imageUrlLarge
        case reward, participantCount, avgAchieveRatio, maxAchieveDays
    }
}
