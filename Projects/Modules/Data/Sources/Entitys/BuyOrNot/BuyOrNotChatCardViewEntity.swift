//
//  BuyOrNotChatCardViewEntity.swift
//  Data
//
//  Created by Jae hyung Kim on 4/8/26.
//

import Foundation
import Domain

public struct BuyOrNotChatCardViewEntity: Entity {
    public let imageUrl: URL?
    public let productName: String
    public let price: String
    public let writerName: String
    public let category: String?
    
    public init(imageUrl: URL?, productName: String, price: String, writerName: String, category: String?) {
        self.imageUrl = imageUrl
        self.productName = productName
        self.price = price
        self.writerName = writerName
        self.category = category
    }
}
