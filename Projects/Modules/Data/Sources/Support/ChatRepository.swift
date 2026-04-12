//
//  ChatRepository.swift
//  Data
//
//  Created by Atlas on 4/7/26.
//

import Foundation
import ComposableArchitecture
import Utils

/// 채팅 도메인 오케스트레이션
/// - HTTP / WebSocket / Realm 캐시 흐름의 단일 진입점
/// - Feature 계층은 이 repository 만 의존한다.
public final class ChatRepository: Sendable {

    private let networkManager: NetworkManager
    private let socketClient: ChatSocketClient
    private let localStore: ChatLocalStore
    private let mapper: ChatMapper

    public init(
        networkManager: NetworkManager = .shared,
        socketClient: ChatSocketClient = ChatSocketClient(),
        localStore: ChatLocalStore = ChatLocalStore(),
        mapper: ChatMapper = ChatMapper()
    ) {
        self.networkManager = networkManager
        self.socketClient = socketClient
        self.localStore = localStore
        self.mapper = mapper
    }

    // MARK: - Room list

    public func fetchRoomList(userId: String?, page: Int, size: Int) async throws -> [ChatRoomCardEntity] {
        let dto = try await networkManager.requestNetworkWithRefresh(
            dto: BuyOrNotPagedDTO<BuyOrNotDTO>.self,
            router: BuyOrNotRouter.buyOrNotChatList(userId: userId, page: page, size: size)
        )
        return mapper.map(roomListDTO: dto)
    }

    // MARK: - Local hydrate

    public func loadCachedMessages(roomId: Int) async -> [ChatMessageEntity] {
        await localStore.loadCachedMessages(roomId: roomId)
    }

    // MARK: - History

    /// 최신 페이지 fetch + 캐시 머지
    @discardableResult
    public func fetchLatestHistory(roomId: Int) async throws -> [ChatMessageEntity] {
        let dto = try await networkManager.requestNetworkWithRefresh(
            dto: [ChatHistoryMessageDTO].self,
            router: BuyOrNotRouter.buyOrNotChatHistory(postId: roomId, chatLastId: nil)
        )
        let entities = mapper.map(historyDTOs: dto, roomId: roomId)
        return await localStore.upsertHistoryPage(roomId: roomId, items: entities)
    }

    /// 과거 페이지 fetch + 캐시 머지
    @discardableResult
    public func fetchOlderHistory(roomId: Int) async throws -> [ChatMessageEntity] {
        guard let cursor = await localStore.oldestMessageId(roomId: roomId) else {
            return try await fetchLatestHistory(roomId: roomId)
        }
        let dto = try await networkManager.requestNetworkWithRefresh(
            dto: [ChatHistoryMessageDTO].self,
            router: BuyOrNotRouter.buyOrNotChatHistory(postId: roomId, chatLastId: cursor)
        )
        let entities = mapper.map(historyDTOs: dto, roomId: roomId)
        return await localStore.upsertHistoryPage(roomId: roomId, items: entities)
    }

    public func hasOlderPage(roomId: Int, lastFetchedCount: Int) -> Bool {
        return lastFetchedCount > 0
    }

    // MARK: - Socket

    public func connectSocket(baseURL: URL, roomId: Int) async -> Bool {
        let endpoint = ChatSocketEndpoint(baseURL: baseURL, buyOrNotId: String(roomId))
        return await socketClient.connect(endpoint: endpoint)
    }

    public func disconnectSocket() async {
        await socketClient.disconnect()
    }

    public func observeSocketErrors() async -> AsyncStream<SocketManager.ManagerError> {
        await socketClient.observeErrors()
    }

    public func observeSocketLifecycle() async -> AsyncStream<SocketManager.LifecycleEvent> {
        await socketClient.observeLifecycle()
    }

    /// 수신 메시지 스트림 (Realm upsert 후 최신 캐시 배열을 emit)
    public func incomingMessages(roomId: Int) async -> AsyncStream<[ChatMessageEntity]> {
        let stream = await socketClient.subscribeToMessages()
        let store = self.localStore
        return AsyncStream { continuation in
            let task = Task {
                for await entity in stream {
                    guard entity.buyOrNotId == roomId else { continue }
                    let updated = await store.upsertIncoming(entity)
                    continuation.yield(updated)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    public func sendMessage(_ request: ChatSendRequestDTO) async -> Bool {
        await socketClient.sendMessage(request)
    }
}

extension ChatRepository: DependencyKey {
    public static let liveValue: ChatRepository = ChatRepository()
}

extension DependencyValues {
    public var chatRepository: ChatRepository {
        get { self[ChatRepository.self] }
        set { self[ChatRepository.self] = newValue }
    }
}
