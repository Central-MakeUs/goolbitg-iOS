import XCTest
@testable import Data

final class ChatLocalStoreTests: XCTestCase {

    private func makeStore(id: String = UUID().uuidString) -> ChatLocalStore {
        let config = ChatLocalStore.inMemoryConfiguration(identifier: id)
        return ChatLocalStore(configuration: config)
    }

    func testUpsertHistoryDeduplicatesByMessageId() async {
        let store = makeStore()
        let entity = ChatMessageEntity(
            id: 1,
            buyOrNotId: 10,
            userId: "u1",
            username: "n1",
            content: "hello",
            sentDateTime: "2026-04-02T10:00:00",
            sentAt: Date(timeIntervalSince1970: 100)
        )

        _ = await store.upsertHistoryPage(roomId: 10, items: [entity, entity])
        let cached = await store.loadCachedMessages(roomId: 10)

        XCTAssertEqual(cached.count, 1)
        XCTAssertEqual(cached.first?.id, 1)
    }

    func testOldestMessageIdReturnsMinimum() async {
        let store = makeStore()
        let items: [ChatMessageEntity] = (1...5).map { i in
            ChatMessageEntity(
                id: i,
                buyOrNotId: 10,
                userId: "u",
                username: "n",
                content: "c\(i)",
                sentDateTime: "2026-04-02T10:00:00",
                sentAt: Date(timeIntervalSince1970: TimeInterval(i))
            )
        }
        _ = await store.upsertHistoryPage(roomId: 10, items: items)
        let oldest = await store.oldestMessageId(roomId: 10)
        XCTAssertEqual(oldest, 1)
    }

    func testIncomingMessageUpdatesRoomMetadata() async {
        let store = makeStore()
        let entity = ChatMessageEntity(
            id: 42,
            buyOrNotId: 10,
            userId: "u",
            username: "n",
            content: "preview",
            sentDateTime: "2026-04-02T10:00:00",
            sentAt: Date(timeIntervalSince1970: 200)
        )
        _ = await store.upsertIncoming(entity)

        let metadata = await store.roomMetadata(roomId: 10)
        XCTAssertEqual(metadata?.lastSyncedMessageId, 42)
        XCTAssertEqual(metadata?.oldestCachedMessageId, 42)
        XCTAssertEqual(metadata?.lastMessagePreview, "preview")
    }

    func testCachedMessagesSortedAscending() async {
        let store = makeStore()
        let items = [
            ChatMessageEntity(id: 2, buyOrNotId: 10, userId: "u", username: "n", content: "b", sentDateTime: "x", sentAt: Date(timeIntervalSince1970: 200)),
            ChatMessageEntity(id: 1, buyOrNotId: 10, userId: "u", username: "n", content: "a", sentDateTime: "x", sentAt: Date(timeIntervalSince1970: 100))
        ]
        _ = await store.upsertHistoryPage(roomId: 10, items: items)
        let cached = await store.loadCachedMessages(roomId: 10)
        XCTAssertEqual(cached.map(\.id), [1, 2])
    }

    func testCachedMessagesSortsByParsedDateWhenStoredSentAtIsNil() async {
        let store = makeStore()
        let items = [
            ChatMessageEntity(id: 2, buyOrNotId: 10, userId: "u", username: "n", content: "later", sentDateTime: "2026-04-07T07:33:14+01:00", sentAt: nil),
            ChatMessageEntity(id: 1, buyOrNotId: 10, userId: "u", username: "n", content: "earlier", sentDateTime: "2026-04-07T07:29:08+01:00", sentAt: nil)
        ]

        _ = await store.upsertHistoryPage(roomId: 10, items: items)
        let cached = await store.loadCachedMessages(roomId: 10)

        XCTAssertEqual(cached.map(\.id), [1, 2])
    }

    func testHistoryUpsertPreservesExistingUserIdWhenHistoryPayloadOmitsIt() async {
        let store = makeStore()
        let socketEntity = ChatMessageEntity(
            id: 42,
            buyOrNotId: 10,
            userId: "socket-user",
            username: "n",
            content: "hello",
            sentDateTime: "2026-04-02T10:00:00",
            sentAt: Date(timeIntervalSince1970: 200)
        )
        _ = await store.upsertIncoming(socketEntity)

        let historyEntity = ChatMessageEntity(
            id: 42,
            buyOrNotId: 10,
            userId: "",
            username: "n",
            content: "hello",
            sentDateTime: "2026-04-02T10:00:00",
            sentAt: Date(timeIntervalSince1970: 200)
        )
        _ = await store.upsertHistoryPage(roomId: 10, items: [historyEntity])

        let cached = await store.loadCachedMessages(roomId: 10)
        XCTAssertEqual(cached.first?.userId, "socket-user")
    }
}
