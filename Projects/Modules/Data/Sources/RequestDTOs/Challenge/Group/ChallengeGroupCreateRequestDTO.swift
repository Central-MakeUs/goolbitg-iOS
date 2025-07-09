//
//  ChallengeGroupCreateRequestDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 7/9/25.
//

import Foundation

public struct ChallengeGroupCreateRequestDTO: Encodable {
    public let title: String
    public let hashtags: [String]
    public let reward: Int
    public let maxSize: Int
    public let isHidden: Bool
    public let password: String?
    
    public init(
        title: String,
        hashtags: [String],
        reward: Int,
        maxSize: Int,
        isHidden: Bool,
        password: String?
    ) {
        self.title = title
        self.hashtags = hashtags
        self.reward = reward
        self.maxSize = maxSize
        self.isHidden = isHidden
        self.password = password
    }
}
