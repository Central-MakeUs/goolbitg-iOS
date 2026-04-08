//
//  ChatSocketClient.swift
//  Data
//
//  Created by Atlas on 4/3/26.
//

import Foundation
import ComposableArchitecture

/// Chat-specific SocketManager consumer
/// - Owns the integration seam between chat protocol and transport
/// - Only file that knows both chat endpoint strings AND SocketManager usage
public actor ChatSocketClient {

    // MARK: - Dependencies
    private let socketManager: SocketManager
    private let mapper: ChatMapper

    // MARK: - State
    private var endpoint: ChatSocketEndpoint?

    // MARK: - Initialization

    public init(
        socketManager: SocketManager = .shared,
        mapper: ChatMapper = ChatMapper()
    ) {
        self.socketManager = socketManager
        self.mapper = mapper
    }

    // MARK: - Connection

    public func connect(endpoint: ChatSocketEndpoint) async -> Bool {
        self.endpoint = endpoint
        let config = SocketManager.Configuration(url: endpoint.connectURL)
        let lifecycleStream = await socketManager.observeLifecycle()
        await socketManager.configure(config)
        await socketManager.connect()

        return await withTaskGroup(of: Bool.self) { group in
            group.addTask {
                for await event in lifecycleStream {
                    switch event {
                    case .connected:
                        return true
                    case .disconnected:
                        return false
                    default:
                        continue
                    }
                }
                return false
            }

            group.addTask {
                try? await Task.sleep(for: .seconds(5))
                return false
            }

            let result = await group.next() ?? false
            group.cancelAll()
            return result
        }
    }

    public func disconnect() async {
        await socketManager.disconnect()
    }

    // MARK: - Messaging

    /// Subscribes to incoming chat messages
    /// - Returns: AsyncStream of chat message entities
    public func subscribeToMessages() async -> AsyncStream<ChatMessageEntity> {
        guard let endpoint else {
            return AsyncStream { $0.finish() }
        }

        let subscribeDest = endpoint.subscribeDestination
        let eventStream = await socketManager.listen(event: subscribeDest)
        let mapper = self.mapper

        return AsyncStream { continuation in
            let task = Task {
                for await event in eventStream {
                    if let firstItem = event.items.first,
                       let dict = firstItem as? [String: Any],
                       let dto = ChatSocketClient.decodeChatMessageDTO(from: dict) {
                        let entity = mapper.map(dto: dto)
                        #if DEBUG
                        print("📩 ChatSocketClient received raw dict: \(dict)")
                        print("📩 ChatSocketClient sentDateTime raw: \(dto.sentDateTime)")
                        print("📩 ChatSocketClient parsed sentAt: \(String(describing: entity.sentAt))")
                        #endif
                        continuation.yield(entity)
                    } else {
                        #if DEBUG
                        if let firstItem = event.items.first {
                            print("⚠️ ChatSocketClient failed to decode incoming message: \(firstItem)")
                        } else {
                            print("⚠️ ChatSocketClient received empty event items for: \(event.name)")
                        }
                        #endif
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Sends a chat message
    public func sendMessage(_ request: ChatSendRequestDTO) async {
        guard let endpoint else { return }
        let sendDest = endpoint.sendDestination
        let payload = mapper.mapToOutboundPayload(dto: request)
        await socketManager.emit(event: sendDest, items: [payload])
    }

    // MARK: - Lifecycle & Errors

    public func observeLifecycle() async -> AsyncStream<SocketManager.LifecycleEvent> {
        await socketManager.observeLifecycle()
    }

    public func observeErrors() async -> AsyncStream<SocketManager.ManagerError> {
        await socketManager.observeErrors()
    }

    // MARK: - Decoding

    /// 서버 샘플은 numeric `id`/`buyOrNotId` 를 보내므로 Int 또는 String 둘 다 허용한다.
    static func decodeChatMessageDTO(from dict: [String: Any]) -> ChatMessageDTO? {
        guard let id = intValue(dict["id"]),
              let buyOrNotId = intValue(dict["buyOrNotId"]),
              let userId = dict["userId"] as? String,
              let username = dict["username"] as? String,
              let content = dict["content"] as? String,
              let sentDateTime = dict["sentDateTime"] as? String else {
            return nil
        }
        return ChatMessageDTO(
            id: id,
            buyOrNotId: buyOrNotId,
            userId: userId,
            username: username,
            content: content,
            sentDateTime: sentDateTime
        )
    }

    private static func intValue(_ any: Any?) -> Int? {
        if let i = any as? Int { return i }
        if let n = any as? NSNumber { return n.intValue }
        if let s = any as? String { return Int(s) }
        return nil
    }
}

extension ChatSocketClient: DependencyKey {
    public static let liveValue: ChatSocketClient = ChatSocketClient()
}

extension DependencyValues {
    public var chatSocketClient: ChatSocketClient {
        get { self[ChatSocketClient.self] }
        set { self[ChatSocketClient.self] = newValue }
    }
}
