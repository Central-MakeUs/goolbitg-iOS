//
//  BuyOrNotCardViewEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation

struct BuyOrNotCardViewEntity: Entity {
    let id: String
    let imageUrl: URL?
    let itemName: String
    let priceString: String
    let goodReason: String
    let badReason: String
    
    let goodVoteCount: String
    let badVoteCount: String
}
