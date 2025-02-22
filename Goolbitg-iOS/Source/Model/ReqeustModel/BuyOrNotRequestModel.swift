//
//  BuyOrNotRequestModel.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation

/// 살까말까 포스트 등록
struct BuyOrNotRequestModel: Encodable {
    let productName: String
    let productPrice: Int
    let productImageUrl: String
    let goodReason: String
    let badReason: String
}
