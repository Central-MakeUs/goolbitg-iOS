import XCTest
@testable import Data

final class ChatMapperTests: XCTestCase {
    func testMapFromDTOToEntity() {
        let mapper = ChatMapper()
        let dto = ChatMessageDTO(
            id: "msg-1",
            buyOrNotId: "bon-1",
            userId: "user-1",
            username: "alice",
            content: "hello",
            sentDateTime: "2026-04-03T12:34:56Z"
        )

        let entity = mapper.map(dto: dto)

        XCTAssertEqual(entity.id, "msg-1")
        XCTAssertEqual(entity.buyOrNotId, "bon-1")
        XCTAssertEqual(entity.userId, "user-1")
        XCTAssertEqual(entity.username, "alice")
        XCTAssertEqual(entity.content, "hello")
        XCTAssertEqual(entity.sentDateTime, "2026-04-03T12:34:56Z")
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
}
