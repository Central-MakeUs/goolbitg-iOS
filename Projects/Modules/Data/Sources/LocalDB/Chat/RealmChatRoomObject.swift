//
//  RealmChatRoomObject.swift
//  Data
//
//  Created by Atlas on 4/7/26.
//

import Foundation
import RealmSwift

/// 채팅방 메타데이터 Realm 객체
/// - room name 은 서버 미제공이므로 저장하지 않는다.
public final class RealmChatRoomObject: Object {
    @Persisted(primaryKey: true) public var roomId: Int
    @Persisted public var lastSyncedMessageId: Int?
    @Persisted public var oldestCachedMessageId: Int?
    @Persisted public var lastMessagePreview: String?
    @Persisted public var lastMessageSentAt: Date?
    @Persisted public var updatedAt: Date = Date()

    public override init() { super.init() }

    public convenience init(roomId: Int) {
        self.init()
        self.roomId = roomId
    }
}
