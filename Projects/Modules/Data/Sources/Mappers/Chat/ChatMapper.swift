//
//  ChatMapper.swift
//  Data
//
//  Created by Atlas on 4/3/26.
//

import Foundation

/// Maps between chat DTOs and app-facing entities
public final class ChatMapper: Sendable {
    
    public init() {}
    
    /// Maps inbound DTO to app-facing entity
    /// - Parameter dto: The decoded chat message DTO from websocket
    /// - Returns: App-facing ChatMessageEntity
    public func map(dto: ChatMessageDTO) -> ChatMessageEntity {
        ChatMessageEntity(
            id: dto.id,
            buyOrNotId: dto.buyOrNotId,
            userId: dto.userId,
            username: dto.username,
            content: dto.content,
            sentDateTime: dto.sentDateTime
        )
    }
    
    /// Transforms outbound request DTO to socket-compatible dictionary
    /// - Parameter dto: The send request DTO
    /// - Returns: Dictionary for SocketManager emit
    public func mapToOutboundPayload(dto: ChatSendRequestDTO) -> [String: Any] {
        [
            "userId": dto.userId,
            "username": dto.username,
            "content": dto.content
        ]
    }
}
