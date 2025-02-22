//
//  BuyOrNotPagedDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import Foundation

struct BuyOrNotPagedDTO<D: DTO>: DTO {
    /// 총 아이템 수
    let totalSize: Int
    /// 총 페이지 수
    let totalPages: Int
    /// 아이템 수
    let size: Int
    /// 페이지 번호
    let page: Int
    /// 아이템들
    let items: [D]
}
