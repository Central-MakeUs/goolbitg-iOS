//
//  RealmChatMessageObject.swift
//  Data
//
//  Created by Atlas on 4/7/26.
//

import Foundation
import RealmSwift

/// 로컬 캐시용 채팅 메시지 Realm 객체
/// - 서버 messageId 를 단일 PK 로 사용한다.
public final class RealmChatMessageObject: Object {
    @Persisted(primaryKey: true) public var messageId: Int
    @Persisted(indexed: true) public var roomId: Int
    @Persisted public var userId: String = ""
    @Persisted public var username: String = ""
    @Persisted public var content: String = ""
    @Persisted public var sentDateTimeRaw: String = ""
    @Persisted(indexed: true) public var sentAt: Date?
    @Persisted public var createdAtLocal: Date = Date()

    public override init() { super.init() }

    public convenience init(
        messageId: Int,
        roomId: Int,
        userId: String,
        username: String,
        content: String,
        sentDateTimeRaw: String,
        sentAt: Date?,
        createdAtLocal: Date = Date()
    ) {
        self.init()
        self.messageId = messageId
        self.roomId = roomId
        self.userId = userId
        self.username = username
        self.content = content
        self.sentDateTimeRaw = sentDateTimeRaw
        self.sentAt = sentAt
        self.createdAtLocal = createdAtLocal
    }
}
