//
//  ChatLocalStore.swift
//  Data
//
//  Created by Atlas on 4/7/26.
//

import Foundation
import RealmSwift
import ComposableArchitecture

/// Realm 기반 채팅 캐시 저장소
/// - 모든 read/write 는 `@RealmActor` 격리 안에서만 수행된다.
/// - 외부에는 항상 Sendable value(`ChatMessageEntity`) 만 노출한다.
public final class ChatLocalStore: @unchecked Sendable {

    private let configuration: Realm.Configuration

    public init(configuration: Realm.Configuration = ChatLocalStore.defaultConfiguration()) {
        self.configuration = configuration
    }

    public static func defaultConfiguration() -> Realm.Configuration {
        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = 1
        config.objectTypes = [RealmChatMessageObject.self, RealmChatRoomObject.self]
        return config
    }

    public static func inMemoryConfiguration(identifier: String = UUID().uuidString) -> Realm.Configuration {
        var config = Realm.Configuration(inMemoryIdentifier: identifier)
        config.objectTypes = [RealmChatMessageObject.self, RealmChatRoomObject.self]
        return config
    }

    @RealmActor
    private func openRealm() async -> Realm? {
        do {
            return try await Realm(configuration: configuration, actor: RealmActor.shared)
        } catch {
            return nil
        }
    }

    // MARK: - Read

    @RealmActor
    public func loadCachedMessages(roomId: Int) async -> [ChatMessageEntity] {
        guard let realm = await openRealm() else { return [] }
        let results = realm.objects(RealmChatMessageObject.self)
            .where { $0.roomId == roomId }
            .sorted(byKeyPath: "sentAt", ascending: true)
        return Self.stablySortedMessages(results.map { Self.entity(from: $0) })
    }

    @RealmActor
    public func oldestMessageId(roomId: Int) async -> Int? {
        guard let realm = await openRealm() else { return nil }
        let results = realm.objects(RealmChatMessageObject.self)
            .where { $0.roomId == roomId }
            .sorted(byKeyPath: "messageId", ascending: true)
        return results.first?.messageId
    }

    @RealmActor
    public func roomMetadata(roomId: Int) async -> RealmChatRoomMetadataValue? {
        guard let realm = await openRealm() else { return nil }
        guard let obj = realm.object(ofType: RealmChatRoomObject.self, forPrimaryKey: roomId) else {
            return nil
        }
        return RealmChatRoomMetadataValue(
            roomId: obj.roomId,
            lastSyncedMessageId: obj.lastSyncedMessageId,
            oldestCachedMessageId: obj.oldestCachedMessageId,
            lastMessagePreview: obj.lastMessagePreview,
            lastMessageSentAt: obj.lastMessageSentAt
        )
    }

    // MARK: - Write

    @RealmActor
    public func upsertHistoryPage(roomId: Int, items: [ChatMessageEntity]) async -> [ChatMessageEntity] {
        guard let realm = await openRealm() else { return [] }
        do {
            try await realm.asyncWrite {
                for entity in items {
                    let preservedUserId: String
                    if entity.userId.isEmpty,
                       let existing = realm.object(ofType: RealmChatMessageObject.self, forPrimaryKey: entity.id) {
                        preservedUserId = existing.userId
                    } else {
                        preservedUserId = entity.userId
                    }

                    let object = RealmChatMessageObject(
                        messageId: entity.id,
                        roomId: entity.buyOrNotId,
                        userId: preservedUserId,
                        username: entity.username,
                        content: entity.content,
                        sentDateTimeRaw: entity.sentDateTime,
                        sentAt: entity.sentAt
                    )
                    realm.add(object, update: .modified)
                }
                Self.refreshRoomMetadata(realm: realm, roomId: roomId)
            }
        } catch {
            return []
        }
        return await loadCachedMessages(roomId: roomId)
    }

    @RealmActor
    public func upsertIncoming(_ entity: ChatMessageEntity) async -> [ChatMessageEntity] {
        let roomId = entity.buyOrNotId
        guard let realm = await openRealm() else { return [] }
        do {
            try await realm.asyncWrite {
                let object = RealmChatMessageObject(
                    messageId: entity.id,
                    roomId: roomId,
                    userId: entity.userId,
                    username: entity.username,
                    content: entity.content,
                    sentDateTimeRaw: entity.sentDateTime,
                    sentAt: entity.sentAt
                )
                realm.add(object, update: .modified)
                Self.refreshRoomMetadata(realm: realm, roomId: roomId)
            }
        } catch {
            return []
        }
        return await loadCachedMessages(roomId: roomId)
    }

    @RealmActor
    public func clearRoom(roomId: Int) async {
        guard let realm = await openRealm() else { return }
        do {
            try await realm.asyncWrite {
                let messages = realm.objects(RealmChatMessageObject.self).where { $0.roomId == roomId }
                realm.delete(messages)
                if let room = realm.object(ofType: RealmChatRoomObject.self, forPrimaryKey: roomId) {
                    realm.delete(room)
                }
            }
        } catch {
            return
        }
    }

    // MARK: - Helpers

    private static func refreshRoomMetadata(realm: Realm, roomId: Int) {
        let results = realm.objects(RealmChatMessageObject.self).where { $0.roomId == roomId }
        let oldest = results.sorted(byKeyPath: "messageId", ascending: true).first
        let latest = results.sorted(byKeyPath: "messageId", ascending: false).first

        let room = realm.object(ofType: RealmChatRoomObject.self, forPrimaryKey: roomId)
            ?? RealmChatRoomObject(roomId: roomId)
        room.oldestCachedMessageId = oldest?.messageId
        room.lastSyncedMessageId = latest?.messageId
        room.lastMessagePreview = latest?.content
        room.lastMessageSentAt = latest?.sentAt
        room.updatedAt = Date()
        realm.add(room, update: .modified)
    }

    private static func entity(from obj: RealmChatMessageObject) -> ChatMessageEntity {
        ChatMessageEntity(
            id: obj.messageId,
            buyOrNotId: obj.roomId,
            userId: obj.userId,
            username: obj.username,
            content: obj.content,
            sentDateTime: obj.sentDateTimeRaw,
            sentAt: obj.sentAt
        )
    }

    private static func stablySortedMessages(_ messages: [ChatMessageEntity]) -> [ChatMessageEntity] {
        messages.sorted { lhs, rhs in
            let lhsDate = lhs.sentAt ?? ChatMapper.parseSentDateTime(lhs.sentDateTime) ?? .distantPast
            let rhsDate = rhs.sentAt ?? ChatMapper.parseSentDateTime(rhs.sentDateTime) ?? .distantPast

            if lhsDate != rhsDate {
                return lhsDate < rhsDate
            }

            return lhs.id < rhs.id
        }
    }
}

/// Realm room metadata 의 Sendable value 표현
public struct RealmChatRoomMetadataValue: Sendable, Equatable {
    public let roomId: Int
    public let lastSyncedMessageId: Int?
    public let oldestCachedMessageId: Int?
    public let lastMessagePreview: String?
    public let lastMessageSentAt: Date?
}

extension ChatLocalStore: DependencyKey {
    public static let liveValue: ChatLocalStore = ChatLocalStore()
}

extension DependencyValues {
    public var chatLocalStore: ChatLocalStore {
        get { self[ChatLocalStore.self] }
        set { self[ChatLocalStore.self] = newValue }
    }
}
