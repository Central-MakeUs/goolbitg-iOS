//
//  BuyOrNotCardViewEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation
import Domain

public struct BuyOrNotCardViewEntity: Entity, Identifiable {
    public let id: String
    public let userID: String
    public let imageUrl: URL?
    public let itemName: String
    public let priceString: String
    public let goodReason: String
    public let badReason: String
    
    public var goodVoteCount: String
    public var badVoteCount: String
    
    public let goodMoreOrBadMore: GoodOrBadOrNot
    public var ifNeedIndex = 0
    
    public init(
        id: String,
        userID: String,
        imageUrl: URL?,
        itemName: String,
        priceString: String,
        goodReason: String,
        badReason: String,
        goodVoteCount: String,
        badVoteCount: String,
        goodMoreOrBadMore: GoodOrBadOrNot,
        ifNeedIndex: Int = 0
    ) {
        self.id = id
        self.userID = userID
        self.imageUrl = imageUrl
        self.itemName = itemName
        self.priceString = priceString
        self.goodReason = goodReason
        self.badReason = badReason
        self.goodVoteCount = goodVoteCount
        self.badVoteCount = badVoteCount
        self.goodMoreOrBadMore = goodMoreOrBadMore
        self.ifNeedIndex = ifNeedIndex
    }
}

public enum GoodOrBadOrNot: Equatable {
    case good
    case bad
    case none
}

extension BuyOrNotCardViewEntity {
    
    public static func dummy() -> [BuyOrNotCardViewEntity] {
        [
            BuyOrNotCardViewEntity(
                id: UUID().uuidString, userID: "asd",
                imageUrl: URL(string: "https://health.chosun.com/site/data/img_dir/2024/04/23/2024042302394_0.jpg"),
                itemName: "나이키 ACG 써마핏 ADV 루나 레이크 패딩 BC1220",
                priceString: "70,000원",
                goodReason: "누구나 좋아하는 강아지",
                badReason: "누구나 싫어하는 강아지",
                goodVoteCount: "\(Int.random(in: 0...100))",
                badVoteCount: "1",
                goodMoreOrBadMore: .bad
            )
        ]
    }
}
