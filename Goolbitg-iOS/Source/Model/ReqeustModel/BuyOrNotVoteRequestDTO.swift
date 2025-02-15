//
//  BuyOrNotVoteRequestDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation

struct BuyOrNotVoteRequestDTO: Encodable {
    var vote: BuyOrNotVote
}

enum BuyOrNotVote: String, Encodable {
    case good = "GOOD"
    case bad = "BAD"
}
