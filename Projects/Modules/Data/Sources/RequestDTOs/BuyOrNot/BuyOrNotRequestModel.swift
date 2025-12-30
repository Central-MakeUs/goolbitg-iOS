//
//  BuyOrNotRequestModel.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation

/// 살까말까 포스트 등록
public struct BuyOrNotRequestModel: Encodable {
    public let productName: String
    public let productPrice: Int
    public let productImageUrl: String
    public let goodReason: String
    public let badReason: String
    
    public init(
        productName: String,
        productPrice: Int,
        productImageUrl: String,
        goodReason: String,
        badReason: String
    ) {
        self.productName = productName
        self.productPrice = productPrice
        self.productImageUrl = productImageUrl
        self.goodReason = goodReason
        self.badReason = badReason
    }
}
