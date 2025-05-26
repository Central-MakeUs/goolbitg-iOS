//
//  UserHabitResultEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import Domain

public struct UserHabitResultEntity: Entity {
    public let topTitle: String
    
    public let stepTitle: String
    public let nameTitle: String
    public let imageUrl: URL?
    public let shareImageUrl: URL?
    public let spendingScore: String
    public let sameCount: String
    
    
    public init(
        topTitle: String,
        stepTitle: String,
        nameTitle: String,
        imageUrl: URL?,
        shareImageUrl: URL?,
        spendingScore: String,
        sameCount: String
    ) {
        self.topTitle = topTitle
        self.stepTitle = stepTitle
        self.nameTitle = nameTitle
        self.imageUrl = imageUrl
        self.shareImageUrl = shareImageUrl
        self.spendingScore = spendingScore
        self.sameCount = sameCount
    }
}
