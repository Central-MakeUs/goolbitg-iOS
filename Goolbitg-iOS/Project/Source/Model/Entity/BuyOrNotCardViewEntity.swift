//
//  BuyOrNotCardViewEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation

struct BuyOrNotCardViewEntity: Entity, Identifiable {
    let id: String
    let userID: String
    let imageUrl: URL?
    let itemName: String
    let priceString: String
    let goodReason: String
    let badReason: String
    
    var goodVoteCount: String
    var badVoteCount: String
    
    let goodMoreOrBadMore: GoodOrBadOrNot
    var ifNeedIndex = 0
}

enum GoodOrBadOrNot: Equatable {
    case good
    case bad
    case none
}

extension BuyOrNotCardViewEntity {
    
    static func dummy() -> [BuyOrNotCardViewEntity] {
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
