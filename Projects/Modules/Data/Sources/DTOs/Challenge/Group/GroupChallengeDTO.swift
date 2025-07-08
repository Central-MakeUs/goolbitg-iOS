//
//  GroupChallengeDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 5/27/25.
//

import Foundation
import Domain

/// 그룹 챌린지
public struct GroupChallengeDTO: DTO {
    
    /// Challenge Group ID
    public let id: Int
    
    /// Challenge Creator
    public let ownerId: String
    
    /// Challenge Title
    public let title: String
    
    /// HashTag Lists
    public let hashtags: [String]
    
    /// Max People
    public let maxSize: Int
    
    /// Participating People Count
    public let peopleCount: Int
    
    /// Secret Room Trigger
    public let isHidden: Bool

    /// reward
    public let reward: Int
    
    /// Password
    ///
    /// `minimum: 4, maximum: 4`
    public let password: String?
    
    /// 평균 달성일
    public let avgAchieveRatio: Double
    
    /// 최대 달성일
    public let maxAchieveDays: Double
}
