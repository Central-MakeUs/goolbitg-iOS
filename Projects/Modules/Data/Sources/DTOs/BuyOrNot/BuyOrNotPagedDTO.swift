//
//  BuyOrNotPagedDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import Foundation
import Domain

public struct BuyOrNotPagedDTO<D: DTO>: DTO {
    /// 총 아이템 수
    public let totalSize: Int
    /// 총 페이지 수
    public let totalPages: Int
    /// 아이템 수
    public let size: Int
    /// 페이지 번호
    public let page: Int
    /// 아이템들
    public let items: [D]
}
