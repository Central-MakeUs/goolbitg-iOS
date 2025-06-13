//
//  ChallengeRankEntity.swift
//  Data
//
//  Created by Jae hyung Kim on 6/13/25.
//

import Foundation
import Domain

public struct ChallengeRankEntity: Entity {
    public let userID: String
    public let imageURL: String?
    public let name: String
    public let priceText: String
    
    public init(
        userID: String,
        imageURL: String?,
        name: String,
        priceText: String
    ) {
        self.userID = userID
        self.imageURL = imageURL
        self.name = name
        self.priceText = priceText
    }
}
