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
    
    /// Group Representative Image URL String
    public let imageUrl: String
    
    /// Secret Room Trigger
    public let isHidden: Bool
    
    /// Password
    ///
    /// `minimum: 4, maximum: 4`
    public let password: String
    
}
