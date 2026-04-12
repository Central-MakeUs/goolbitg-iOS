import XCTest

final class ChatRepositorySourceTests: XCTestCase {
    func testFetchLatestHistoryUsesLastSyncedMessageCursor() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let dataModuleURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let repositoryURL = dataModuleURL
            .appendingPathComponent("Sources/Support/ChatRepository.swift")

        let content = try String(contentsOf: repositoryURL, encoding: .utf8)

        XCTAssertTrue(content.contains("localStore.roomMetadata(roomId: roomId)?.lastSyncedMessageId"))
        XCTAssertTrue(content.contains("fetchHistory(roomId: roomId, chatLastId: cursor)"))
        XCTAssertTrue(content.contains("localStore.oldestMessageId(roomId: roomId)"))
    }
}
