//
//  BuyOrNotVoteDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import Foundation
import Domain

/// 투표수
public struct BuyOrNotVoteDTO: DTO {
    public let goodVoteCount: Int
    public let badVoteCount: Int
}
