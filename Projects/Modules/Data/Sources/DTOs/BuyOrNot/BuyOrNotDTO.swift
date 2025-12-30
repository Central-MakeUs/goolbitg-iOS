//
//  BuyOrNotDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import Foundation
import Domain

public struct BuyOrNotDTO: DTO {
    /// 살까말까 등록 ID
    let id: Int?
    /// 작성자 ID
    let writerId: String?
    /// 상품 이름
    let productName: String
    /// 상품 금액
    let productPrice: Int
    /// 상품 이미지 URL
    let productImageUrl: String?
    /// 사야하는 이유
    let goodReason: String
    /// 사면 않되는 이유
    let badReason: String
    /// 좋은 투표 개수
    let goodVoteCount: Int?
    /// 나쁜 투표 개수
    let badVoteCount: Int?
}
