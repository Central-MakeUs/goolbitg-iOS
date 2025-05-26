//
//  ChallengeEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import Domain

public struct ChallengeEntity: Entity {
    public let id: String
    public let imageUrl: URL?
    public let imageUrlLarge: URL?
    public let title: String
    public let subTitle: String?
    /// 달성시 얻는 금액
    public let reward: String?
    /// 챌린지 참여 인원
    public let participantCount: String
    /// 챌린지 평균 달성룰
    public let avgAchiveRatio: String
    /// 가장 오래 진행된 챌린지 일수
    public let maxAchiveDays: Int
    
    public let status: ChallengeStatusCase?
    
    public init(
        id: String,
        imageUrl: URL?,
        imageUrlLarge: URL?,
        title: String,
        subTitle: String?,
        reward: String?,
        participantCount: String,
        avgAchiveRatio: String,
        maxAchiveDays: Int,
        status: ChallengeStatusCase?
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.imageUrlLarge = imageUrlLarge
        self.title = title
        self.subTitle = subTitle
        self.reward = reward
        self.participantCount = participantCount
        self.avgAchiveRatio = avgAchiveRatio
        self.maxAchiveDays = maxAchiveDays
        self.status = status
    }
}
