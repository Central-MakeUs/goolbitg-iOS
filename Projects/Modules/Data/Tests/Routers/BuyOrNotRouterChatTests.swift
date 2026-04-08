import XCTest
@testable import Data

final class BuyOrNotRouterChatTests: XCTestCase {
    func testChatRoomListRouterPathAndQueries() throws {
        let router = BuyOrNotRouter.buyOrNotChatList(userId: "id0001", page: 0, size: 20)
        let request = try router.asURLRequest()
        let url = try XCTUnwrap(request.url?.absoluteString)

        XCTAssertTrue(url.contains("/buyOrNots/chat/list"))
        XCTAssertTrue(url.contains("page=0"))
        XCTAssertTrue(url.contains("size=20"))
        XCTAssertTrue(url.contains("userId=id0001"))
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func testChatRoomListOmitsUserIdWhenNil() throws {
        let router = BuyOrNotRouter.buyOrNotChatList(userId: nil, page: 1, size: 10)
        let request = try router.asURLRequest()
        let url = try XCTUnwrap(request.url?.absoluteString)
        XCTAssertFalse(url.contains("userId"))
        XCTAssertTrue(url.contains("page=1"))
        XCTAssertTrue(url.contains("size=10"))
    }

    func testChatHistoryRouterIncludesPostId() throws {
        let router = BuyOrNotRouter.buyOrNotChatHistory(postId: 7, chatLastId: nil)
        let request = try router.asURLRequest()
        let url = try XCTUnwrap(request.url?.absoluteString)
        XCTAssertTrue(url.contains("/buyOrNots/7/chat/history"))
        XCTAssertFalse(url.contains("chatLastId"))
    }

    func testChatHistoryRouterIncludesChatLastIdWhenPresent() throws {
        let router = BuyOrNotRouter.buyOrNotChatHistory(postId: 7, chatLastId: 99)
        let request = try router.asURLRequest()
        let url = try XCTUnwrap(request.url?.absoluteString)
        XCTAssertTrue(url.contains("/buyOrNots/7/chat/history"))
        XCTAssertTrue(url.contains("chatLastId=99"))
    }
}
