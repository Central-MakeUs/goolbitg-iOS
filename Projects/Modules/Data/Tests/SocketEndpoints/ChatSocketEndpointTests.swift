import Foundation
#if canImport(XCTest)
import XCTest
@testable import Data

final class ChatSocketEndpointTests: XCTestCase {
    func testConnectURLAppendsChat() {
        let baseURL = URL(string: "https://example.com")!
        let endpoint = ChatSocketEndpoint(baseURL: baseURL, buyOrNotId: "123")
        XCTAssertEqual(endpoint.connectURL, baseURL.appendingPathComponent("chat"))
    }

    func testConnectURLDropsAPIRestPathAndUsesRootChatEndpoint() {
        let baseURL = URL(string: "https://example.com/api/v1")!
        let endpoint = ChatSocketEndpoint(baseURL: baseURL, buyOrNotId: "123")

        XCTAssertEqual(endpoint.connectURL, URL(string: "https://example.com/chat"))
    }

    func testSubscribeDestination() {
        let endpoint = ChatSocketEndpoint(baseURL: URL(string: "https://example.com")!, buyOrNotId: "abc")
        XCTAssertEqual(endpoint.subscribeDestination, "/topic/chat/abc")
    }

    func testSendDestination() {
        let endpoint = ChatSocketEndpoint(baseURL: URL(string: "https://example.com")!, buyOrNotId: "xyz")
        XCTAssertEqual(endpoint.sendDestination, "/app/chat/xyz")
    }

    func testSocketManagerHasNoChatProtocolStrings() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let dataModuleURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let socketManagerURL = dataModuleURL
            .appendingPathComponent("Sources/Support/SocketManager.swift")

        let content = try String(contentsOf: socketManagerURL, encoding: .utf8)
        XCTAssertFalse(content.contains("ws://"))
        XCTAssertFalse(content.contains("/chat"))
        XCTAssertFalse(content.contains("/topic/chat"))
        XCTAssertFalse(content.contains("/app/chat"))
    }
}
#endif
