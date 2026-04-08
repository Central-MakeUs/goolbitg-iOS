import XCTest
@testable import Data

final class ChatMessageDTOTests: XCTestCase {
    func testDecodesChatMessageDTOFromPayload() {
        let json = """
        {
            "id": 101,
            "buyOrNotId": 2,
            "userId": "id0001",
            "username": "nickname",
            "content": "message other that other sent",
            "sentDateTime": "2026-04-02T20:55:17.250011"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let dto = try decoder.decode(ChatMessageDTO.self, from: json)
            XCTAssertEqual(dto.id, 101)
            XCTAssertEqual(dto.buyOrNotId, 2)
            XCTAssertEqual(dto.userId, "id0001")
            XCTAssertEqual(dto.username, "nickname")
            XCTAssertEqual(dto.content, "message other that other sent")
            XCTAssertEqual(dto.sentDateTime, "2026-04-02T20:55:17.250011")
        } catch {
            XCTFail("Decoding ChatMessageDTO failed: \(error)")
        }
    }

    func testDecodesChatHistoryMessageDTOArray() throws {
        let json = """
        [
            {"id":101,"username":"a","content":"hi","sentDateTime":"2026-04-02T20:55:17.250011"},
            {"id":102,"username":"b","content":"yo","sentDateTime":"2026-04-02T20:56:17.250011"}
        ]
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode([ChatHistoryMessageDTO].self, from: json)
        XCTAssertEqual(dto.count, 2)
        XCTAssertEqual(dto.first?.id, 101)
        XCTAssertEqual(dto.first?.username, "a")
        XCTAssertEqual(dto.last?.content, "yo")
    }
}
