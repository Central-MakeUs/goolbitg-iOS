//
//  ChattingViewFeatureTests.swift
//  FeatureCommonTests
//
//  Created by Atlas on 4/7/26.
//

import XCTest
import ComposableArchitecture
@testable import FeatureCommon
@testable import Data

final class ChattingViewFeatureTests: XCTestCase {

    @MainActor
    func testBackTappedEmitsDelegate() async {
        let store = TestStore(
            initialState: ChattingViewFeature.State(
                userName: "tester",
                userID: "user-1",
                model: makeModel(id: "101")
            )
        ) {
            ChattingViewFeature()
        }

        await store.send(.viewEvent(.backTapped))
        await store.receive(.delegate(.backTapped))
    }

    func testBuildListItemsInsertsDateDividers() {
        let entities = [
            ChatMessageEntity(
                id: 1,
                buyOrNotId: 10,
                userId: "me",
                username: "me",
                content: "first",
                sentDateTime: "2026-04-02T10:00:00",
                sentAt: ChatMapper.parseSentDateTime("2026-04-02T10:00:00")
            ),
            ChatMessageEntity(
                id: 2,
                buyOrNotId: 10,
                userId: "other",
                username: "other",
                content: "second",
                sentDateTime: "2026-04-03T10:00:00",
                sentAt: ChatMapper.parseSentDateTime("2026-04-03T10:00:00")
            )
        ]

        let items = ChattingViewFeature.buildListItems(
            from: entities,
            currentUserId: "me",
            currentUserName: "me"
        )

        // 두 개의 다른 날짜 -> date divider 2개 + chat 2개
        XCTAssertEqual(items.count, 4)

        if case .date = items[0] {} else { XCTFail("expected date") }
        if case .chat = items[1] {} else { XCTFail("expected chat") }
        if case .date = items[2] {} else { XCTFail("expected date") }
        if case .chat = items[3] {} else { XCTFail("expected chat") }
    }

    func testBuildListItemsAssignsRightForCurrentUser() {
        let entity = ChatMessageEntity(
            id: 1,
            buyOrNotId: 10,
            userId: "me",
            username: "me",
            content: "hi",
            sentDateTime: "2026-04-02T10:00:00",
            sentAt: ChatMapper.parseSentDateTime("2026-04-02T10:00:00")
        )

        let items = ChattingViewFeature.buildListItems(
            from: [entity],
            currentUserId: "me",
            currentUserName: "me"
        )

        guard case let .chat(message) = items.last else {
            XCTFail("missing chat item")
            return
        }
        XCTAssertEqual(message.type, .right)
        XCTAssertNil(message.userName)
    }

    func testBuildListItemsAssignsLeftForOtherUser() {
        let entity = ChatMessageEntity(
            id: 2,
            buyOrNotId: 10,
            userId: "stranger",
            username: "stranger",
            content: "hi",
            sentDateTime: "2026-04-02T10:00:00",
            sentAt: ChatMapper.parseSentDateTime("2026-04-02T10:00:00")
        )

        let items = ChattingViewFeature.buildListItems(
            from: [entity],
            currentUserId: "me",
            currentUserName: "me"
        )

        guard case let .chat(message) = items.last else {
            XCTFail("missing chat item")
            return
        }
        XCTAssertEqual(message.type, .left)
        XCTAssertEqual(message.userName, "stranger")
    }

    func testNoFakeTaskSleepInReducerSource() throws {
        // 안전망: placeholder loading timer가 다시 들어오지 못하도록 가드
        let testFileURL = URL(fileURLWithPath: #filePath)
        let featureURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/ChatView/ChattingViewFeature.swift")
        let content = try String(contentsOf: featureURL, encoding: .utf8)
        XCTAssertFalse(content.contains("Task.sleep"))
    }

    func testBuildListItemsFallsBackToUserNameWhenHistoryHasNoUserId() {
        let entity = ChatMessageEntity(
            id: 3,
            buyOrNotId: 10,
            userId: "",
            username: "me",
            content: "history",
            sentDateTime: "2026-04-02T10:00:00",
            sentAt: ChatMapper.parseSentDateTime("2026-04-02T10:00:00")
        )

        let items = ChattingViewFeature.buildListItems(
            from: [entity],
            currentUserId: "me-id",
            currentUserName: "me"
        )

        guard case let .chat(message) = items.last else {
            XCTFail("missing chat item")
            return
        }
        XCTAssertEqual(message.type, .right)
        XCTAssertNil(message.userName)
    }

    func testReducerSourceNoLongerUsesRawSocketTransportString() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let featureURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/ChatView/ChattingViewFeature.swift")
        let content = try String(contentsOf: featureURL, encoding: .utf8)

        XCTAssertFalse(content.contains("return message.isEmpty ? \"채팅 소켓 오류가 발생했습니다.\" : message"))
        XCTAssertTrue(content.contains("isReconnecting"))
        XCTAssertTrue(content.contains("socketLifecycleReceived"))
        XCTAssertTrue(content.contains("fetchLatestHistory(roomId: roomId)"))
        XCTAssertFalse(content.contains("if connected {\n                                for await updated in await repo.incomingMessages"))
    }

    func testReducerSourcePreservesPagingStateDuringLatestRefresh() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let featureURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/ChatView/ChattingViewFeature.swift")
        let content = try String(contentsOf: featureURL, encoding: .utf8)

        XCTAssertTrue(content.contains("if state.isInitialLoading {\n                    state.hasNextPage = !messages.isEmpty\n                }"))
        XCTAssertFalse(content.contains("state.hasNextPage = !messages.isEmpty\n                return .none"))
    }

    func testViewSourceShowsReconnectBanner() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let viewURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/ChatView/ChattingView.swift")
        let content = try String(contentsOf: viewURL, encoding: .utf8)

        XCTAssertTrue(content.contains("store.isReconnecting"))
        XCTAssertTrue(content.contains("채팅 연결을 다시 시도하고 있어요"))
    }

    func testViewSourceBackButtonNoLongerUsesDismiss() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let viewURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/ChatView/ChattingView.swift")
        let content = try String(contentsOf: viewURL, encoding: .utf8)

        XCTAssertFalse(content.contains("@Environment(\\.dismiss)"))
        XCTAssertTrue(content.contains("store.send(.viewEvent(.backTapped))"))
    }

    func testReducerSourceContainsBackDelegateFlow() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let featureURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/ChatView/ChattingViewFeature.swift")
        let content = try String(contentsOf: featureURL, encoding: .utf8)

        XCTAssertTrue(content.contains("case delegate(Delegate)"))
        XCTAssertTrue(content.contains("public enum Delegate"))
        XCTAssertTrue(content.contains("case backTapped"))
        XCTAssertTrue(content.contains("return .send(.delegate(.backTapped))"))
    }

    private func makeModel(id: String) -> BuyOrNotCardViewEntity {
        BuyOrNotCardViewEntity(
            id: id,
            userID: "owner",
            userName: "owner",
            imageUrl: nil,
            itemName: "item",
            priceString: "10,000원",
            goodReason: "good",
            badReason: "bad",
            goodVoteCount: "1",
            badVoteCount: "0",
            goodMoreOrBadMore: .good
        )
    }
}
