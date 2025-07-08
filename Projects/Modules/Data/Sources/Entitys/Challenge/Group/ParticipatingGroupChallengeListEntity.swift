//
//  ParticipatingGroupChallengeListEntity.swift
//  Data
//
//  Created by Jae hyung Kim on 5/27/25.
//

import Foundation
import Domain

/// 참여중인 그룹 챌린지 List Entity
public struct ParticipatingGroupChallengeListEntity: Entity {
    
    /// Challenge Group ID
    public let id: Int
    
    /// Challenge Creator
    public let ownerId: String
    
    /// GroupChallengeName
    public let title: String
    
    /// totalWithParticipatingPeopleCount
    ///
    ///  Ex) `3: Currrent / 6: Total`
    public let totalWithParticipatingPeopleCount: String
    
    /// 챌린지 리워드
    public let reward: String
    
    /// hashTag
    ///
    ///  Ex) `#밥먹기 #시켜먹기`
    public let hashTags: [String]
    
    /// Secret Room Trigger
    public let isSecret: Bool
    
    public init(
        id: Int,
        ownerId: String,
        title: String,
        totalWithParticipatingPeopleCount: String,
        hashTags: [String],
        reward: String,
        isSecret: Bool
    ) {
        self.id = id
        self.ownerId = ownerId
        self.title = title
        self.totalWithParticipatingPeopleCount = totalWithParticipatingPeopleCount
        self.hashTags = hashTags
        self.reward = reward
        self.isSecret = isSecret
    }

}
