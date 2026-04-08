//
//  ChatRoomCardEntity.swift
//  Data
//
//  Created by Atlas on 4/7/26.
//

import Foundation

/// 채팅 룸 카드 엔티티
/// - 서버 GET /api/v1/buyOrNots/chat/list 응답을 그대로 BuyOrNotCardViewEntity 로 매핑한 결과를 감싼다
public struct ChatRoomCardEntity: Sendable, Equatable, Hashable, Identifiable {
    public let postId: Int
    public let card: BuyOrNotCardViewEntity

    public var id: Int { postId }

    public init(postId: Int, card: BuyOrNotCardViewEntity) {
        self.postId = postId
        self.card = card
    }
}
