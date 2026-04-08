import XCTest
@testable import Data

final class ChatSocketClientDecodingTests: XCTestCase {
    func testDecodesNumericIdsFromDictionary() {
        let dict: [String: Any] = [
            "id": 101,
            "buyOrNotId": 2,
            "userId": "id0001",
            "username": "nickname",
            "content": "message",
            "sentDateTime": "2026-04-02T20:55:17.250011"
        ]
        let dto = ChatSocketClient.decodeChatMessageDTO(from: dict)
        XCTAssertNotNil(dto)
        XCTAssertEqual(dto?.id, 101)
        XCTAssertEqual(dto?.buyOrNotId, 2)
    }

    func testRejectsMissingFields() {
        let dict: [String: Any] = [
            "id": 1,
            "buyOrNotId": 2,
            "userId": "u"
        ]
        XCTAssertNil(ChatSocketClient.decodeChatMessageDTO(from: dict))
    }

    func testAcceptsStringIDsAsFallback() {
        let dict: [String: Any] = [
            "id": "55",
            "buyOrNotId": "10",
            "userId": "u",
            "username": "n",
            "content": "c",
            "sentDateTime": "2026-04-02T20:55:17.250011"
        ]
        let dto = ChatSocketClient.decodeChatMessageDTO(from: dict)
        XCTAssertEqual(dto?.id, 55)
        XCTAssertEqual(dto?.buyOrNotId, 10)
    }
}
