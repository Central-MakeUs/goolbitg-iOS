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

    func testCoordinatorSourceContainsExplicitChatBackPop() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let coordinatorURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/Tab/TabNavigationCoordinator.swift")
        let content = try String(contentsOf: coordinatorURL, encoding: .utf8)

        XCTAssertTrue(content.contains("case .path(.element(id: _, action: .chatView(.delegate(.backTapped))))"))
        XCTAssertTrue(content.contains("state.path.removeLast()"))
        XCTAssertTrue(content.contains("Coordinator chat teardown - explicit back"))
    }

    func testCoordinatorSourceContainsPathRemovalFallbackDisconnect() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let coordinatorURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/Tab/TabNavigationCoordinator.swift")
        let content = try String(contentsOf: coordinatorURL, encoding: .utf8)

        XCTAssertTrue(content.contains(".onChange(of: \\.path)"))
        XCTAssertTrue(content.contains("Coordinator chat teardown - path removal fallback"))
        XCTAssertTrue(content.contains("suppressNextChatPathRemovalDisconnect"))
        XCTAssertTrue(content.contains("await repo.disconnectSocket(lease: removedLease)"))
    }
}
