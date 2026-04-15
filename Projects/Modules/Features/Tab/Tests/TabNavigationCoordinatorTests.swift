//
//  TabNavigationCoordinatorTests.swift
//  FeatureTabTests
//
//  Created by OpenAI on 4/15/26.
//

import XCTest
import ComposableArchitecture
@testable import FeatureTab
@testable import FeatureCommon
@testable import Data

final class TabNavigationCoordinatorTests: XCTestCase {

    @MainActor
    func testExplicitChatBackPopsRoute() async {
        let store = TestStore(
            initialState: TabNavigationCoordinator.State(
                routes: [
                    .root(.tabView(GBTabBarCoordinator.State()), embedInNavigationView: true),
                    .push(.chatView(ChattingViewFeature.State(
                        userName: "tester",
                        userID: "user-1",
                        model: makeModel(id: "55")
                    )))
                ]
            )
        ) {
            TabNavigationCoordinator()
        } withDependencies: {
            $0.chatRepository = ChatRepository(
                socketClient: ChatSocketClient(socketManager: SocketManager())
            )
        }

        await store.send(.router(.routeAction(id: .chatView, action: .chatView(.delegate(.backTapped))))) {
            $0.routes.removeLast()
            $0.suppressNextChatRouteRemovalDisconnect = false
        }
    }

    func testCoordinatorSourceContainsRouteRemovalFallbackDisconnect() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let coordinatorURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/Tab/TabNavigationCoordinator.swift")
        let content = try String(contentsOf: coordinatorURL, encoding: .utf8)

        XCTAssertTrue(content.contains(".onChange(of: \\.routes)"))
        XCTAssertTrue(content.contains("Coordinator chat teardown - route removal fallback"))
        XCTAssertTrue(content.contains("suppressNextChatRouteRemovalDisconnect"))
        XCTAssertTrue(content.contains("await repo.disconnectSocket(lease: removedLease)"))
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
