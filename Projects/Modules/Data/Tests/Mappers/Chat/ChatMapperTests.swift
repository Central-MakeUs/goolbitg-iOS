import XCTest
@testable import Data

final class ChatMapperTests: XCTestCase {
    func testMapFromDTOToEntity() {
        let mapper = ChatMapper()
        let dto = ChatMessageDTO(
            id: 101,
            buyOrNotId: 2,
            userId: "user-1",
            username: "alice",
            content: "hello",
            sentDateTime: "2026-04-02T20:55:17.250011"
        )

        let entity = mapper.map(dto: dto)

        XCTAssertEqual(entity.id, 101)
        XCTAssertEqual(entity.buyOrNotId, 2)
        XCTAssertEqual(entity.userId, "user-1")
        XCTAssertEqual(entity.username, "alice")
        XCTAssertEqual(entity.content, "hello")
        XCTAssertEqual(entity.sentDateTime, "2026-04-02T20:55:17.250011")
        XCTAssertNotNil(entity.sentAt)
    }

    func testMapOutboundPayloadContainsOnlyContractFields() {
        let mapper = ChatMapper()
        let dto = ChatSendRequestDTO(userId: "user-1", username: "alice", content: "hello")

        let payload = mapper.mapToOutboundPayload(dto: dto)

        XCTAssertEqual(payload["userId"] as? String, "user-1")
        XCTAssertEqual(payload["username"] as? String, "alice")
        XCTAssertEqual(payload["content"] as? String, "hello")
        XCTAssertEqual(payload.count, 3)
    }

    func testMapHistoryDTOInjectsRoomIdAndHandlesArrayShape() {
        let mapper = ChatMapper()
        let dto = [
            ChatHistoryMessageDTO(
                id: 1,
                username: "n",
                content: "c",
                sentDateTime: "2026-04-02T10:00:00"
            )
        ]

        let entities = mapper.map(historyDTOs: dto, roomId: 7)

        XCTAssertEqual(entities.count, 1)
        XCTAssertEqual(entities.first?.id, 1)
        XCTAssertEqual(entities.first?.buyOrNotId, 7)
        XCTAssertEqual(entities.first?.userId, "")
        XCTAssertEqual(entities.first?.username, "n")
    }

    func testKoreanTimeStringFormatting() {
        let date = Date(timeIntervalSince1970: 0)
        let result = ChatMapper.koreanTimeString(from: date)
        XCTAssertFalse(result.isEmpty)
    }
}
