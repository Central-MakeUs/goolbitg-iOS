import XCTest
@testable import Data

final class ChatMessageDTOTests: XCTestCase {
    func testDecodesChatMessageDTOFromPayload() {
        let json = """
        {
            "id": "msg-1",
            "buyOrNotId": "bn-1",
            "userId": "user-1",
            "username": "john",
            "content": "Hello there",
            "sentDateTime": "2026-04-03T12:34:56Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let dto = try decoder.decode(ChatMessageDTO.self, from: json)
            XCTAssertEqual(dto.id, "msg-1")
            XCTAssertEqual(dto.buyOrNotId, "bn-1")
            XCTAssertEqual(dto.userId, "user-1")
            XCTAssertEqual(dto.username, "john")
            XCTAssertEqual(dto.content, "Hello there")
            XCTAssertEqual(dto.sentDateTime, "2026-04-03T12:34:56Z")
        } catch {
            XCTFail("Decoding ChatMessageDTO failed: \(error)")
        }
    }
}
