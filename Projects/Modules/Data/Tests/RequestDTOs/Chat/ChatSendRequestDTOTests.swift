#if canImport(XCTest)
import XCTest
@testable import Data

final class ChatSendRequestDTOTests: XCTestCase {
    func testEncodingMatchesContract() throws {
        let dto = ChatSendRequestDTO(userId: "user-123", username: "alice", content: "Hello there")
        let data = try JSONEncoder().encode(dto)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
        XCTAssertNotNil(jsonObject)
        let dict = jsonObject!
        XCTAssertEqual(dict["userId"], "user-123")
        XCTAssertEqual(dict["username"], "alice")
        XCTAssertEqual(dict["content"], "Hello there")
        // Ensure no extra keys
        XCTAssertEqual(dict.count, 3)
    }
}
#endif
