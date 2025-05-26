//
//  BuyOrNotVoteRequestDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation

public struct BuyOrNotVoteRequestDTO: Encodable {
    public var vote: BuyOrNotVote
    
    public init(vote: BuyOrNotVote) {
        self.vote = vote
    }
}

public enum BuyOrNotVote: String, Encodable {
    case good = "GOOD"
    case bad = "BAD"
}
