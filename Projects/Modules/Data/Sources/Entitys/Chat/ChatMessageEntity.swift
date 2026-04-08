//
//  ChatMessageEntity.swift
//  Data
//
//  Created by Atlas on 4/3/26.
//

import Foundation

/// App-facing chat message entity
/// - Note: sentDateTime is kept as raw String to avoid premature date parsing assumptions
public struct ChatMessageEntity: Sendable, Equatable, Hashable {
    public let id: Int
    public let buyOrNotId: Int
    public let userId: String
    public let username: String
    public let content: String
    public let sentDateTime: String
    public let sentAt: Date?

    public init(
        id: Int,
        buyOrNotId: Int,
        userId: String,
        username: String,
        content: String,
        sentDateTime: String,
        sentAt: Date? = nil
    ) {
        self.id = id
        self.buyOrNotId = buyOrNotId
        self.userId = userId
        self.username = username
        self.content = content
        self.sentDateTime = sentDateTime
        self.sentAt = sentAt
    }
}
