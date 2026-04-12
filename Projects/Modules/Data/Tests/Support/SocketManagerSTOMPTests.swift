import XCTest
@testable import Data

final class SocketManagerSTOMPTests: XCTestCase {
    func testSerializeConnectFrameIncludesHeartbeatNegotiation() {
        let raw = STOMPFrameCodec.serialize(
            STOMPFrame(
                command: "CONNECT",
                headers: [
                    "accept-version": "1.2",
                    "heart-beat": "10000,10000"
                ]
            )
        )

        XCTAssertTrue(raw.hasPrefix("CONNECT\n"))
        XCTAssertTrue(raw.contains("accept-version:1.2"))
        XCTAssertTrue(raw.contains("heart-beat:10000,10000"))
    }

    func testSerializeSendFrameIncludesDestinationAndBody() {
        let raw = STOMPFrameCodec.serialize(
            STOMPFrame(
                command: "SEND",
                headers: [
                    "destination": "/app/chat/2",
                    "content-type": "application/json"
                ],
                body: #"{"content":"hello"}"#
            )
        )

        XCTAssertTrue(raw.hasPrefix("SEND\n"))
        XCTAssertTrue(raw.contains("destination:/app/chat/2"))
        XCTAssertTrue(raw.contains(#"{"content":"hello"}"#))
        XCTAssertTrue(raw.hasSuffix("\u{0000}"))
    }

    func testDeserializeMessageFrameExtractsHeadersAndBody() {
        let raw = "MESSAGE\ndestination:/topic/chat/2\nsubscription:sub-/topic/chat/2\n\n{\"id\":101,\"buyOrNotId\":2,\"userId\":\"id0001\",\"username\":\"nick\",\"content\":\"hello\",\"sentDateTime\":\"2026-04-02T20:55:17.250011\"}\u{0000}"

        let frames = STOMPFrameCodec.deserialize(raw)

        XCTAssertEqual(frames.count, 1)
        XCTAssertEqual(frames.first?.command, "MESSAGE")
        XCTAssertEqual(frames.first?.headers["destination"], "/topic/chat/2")
        XCTAssertTrue(frames.first?.body.contains("\"content\":\"hello\"") == true)
    }

    func testJsonObjectParsesDictionaryBody() {
        let body = #"{"id":101,"buyOrNotId":2,"userId":"id0001","username":"nick","content":"hello","sentDateTime":"2026-04-02T20:55:17.250011"}"#

        let object = STOMPFrameCodec.jsonObject(from: body) as? [String: Any]

        XCTAssertEqual(object?["buyOrNotId"] as? Int, 2)
        XCTAssertEqual(object?["content"] as? String, "hello")
    }

    func testSocketManagerSourceNoLongerUsesZeroHeartbeat() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let dataModuleURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let socketManagerURL = dataModuleURL
            .appendingPathComponent("Sources/Support/SocketManager.swift")

        let content = try String(contentsOf: socketManagerURL, encoding: .utf8)
        XCTAssertFalse(content.contains("\"heart-beat\": \"0,0\""))
        XCTAssertTrue(content.contains("10000,10000"))
        XCTAssertTrue(content.contains("sendPing"))
        XCTAssertTrue(content.contains("reconnectAttempt"))
    }
}
