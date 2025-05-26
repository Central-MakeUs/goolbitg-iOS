//
//  PushListFilterCase.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/1/25.
//

import Foundation
import Domain

public enum PushListFilterCase: Entity, CaseIterable {
    case all
    case challenge
    case voteResult
    case chatting
    
    
    public var title: String {
        return switch self {
        case .all:         "전체"
        case .challenge:    "챌린지"
        case .chatting:     "투표결과"
        case .voteResult:   "채팅"
        }
    }
    
    public var requestMode: String? {
        return switch self {
        case .all:         nil
        case .challenge:    "CHALLENGE"
        case .chatting:     "CHAT"
        case .voteResult:   "VOTE"
        }
    }
}
