//
//  ChallengeEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation

struct ChallengeEntity: Entity {
    let id: String
    let imageUrl: URL?
    let title: String
    let subTitle: String?
    /// 달성시 얻는 금액
    let reward: String?
    /// 챌린지 참여 인원
    let participantCount: String
    /// 챌린지 평균 달성룰
    let avgAchiveRatio: String
    /// 가장 오래 진행된 챌린지 일수
    let maxAchiveDays: Int
}
