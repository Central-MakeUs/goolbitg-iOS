//
//  ChatSocketClient.swift
//  Data
//
//  Created by Atlas on 4/3/26.
//

import Foundation

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
    
    /// Creates a chat socket client
    /// - Parameters:
    ///   - socketManager: The transport manager to use
    ///   - mapper: DTO/Entity mapper
    public init(
        socketManager: SocketManager = .shared,
        mapper: ChatMapper = ChatMapper()
    ) {
        self.socketManager = socketManager
        self.mapper = mapper
    }
    
    // MARK: - Connection
    
    /// Configures and connects to the chat websocket
    /// - Parameter endpoint: The endpoint configuration
    public func connect(endpoint: ChatSocketEndpoint) async {
        self.endpoint = endpoint
        let config = SocketManager.Configuration(url: endpoint.connectURL)
        await socketManager.configure(config)
        await socketManager.connect()
    }
    
    /// Disconnects from the chat websocket
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
        
        return AsyncStream { continuation in
            Task {
                for await event in eventStream {
                    if let firstItem = event.items.first,
                       let dict = firstItem as? [String: Any] {
                        // Attempt to decode from dictionary
                        if let dto = try? self.decodeChatMessageDTO(from: dict) {
                            let entity = self.mapper.map(dto: dto)
                            continuation.yield(entity)
                        }
                    }
                }
                continuation.finish()
            }
        }
    }
    
    /// Sends a chat message
    /// - Parameter request: The send request DTO
    public func sendMessage(_ request: ChatSendRequestDTO) async {
        guard let endpoint else { return }
        
        let sendDest = endpoint.sendDestination
        let payload = mapper.mapToOutboundPayload(dto: request)
        await socketManager.emit(event: sendDest, items: [payload])
    }
    
    // MARK: - Lifecycle & Errors
    
    /// Observes socket lifecycle events
    /// - Returns: AsyncStream of lifecycle events
    public func observeLifecycle() async -> AsyncStream<SocketManager.LifecycleEvent> {
        await socketManager.observeLifecycle()
    }
    
    /// Observes socket errors
    /// - Returns: AsyncStream of manager errors
    public func observeErrors() async -> AsyncStream<SocketManager.ManagerError> {
        await socketManager.observeErrors()
    }
    
    // MARK: - Private Helpers
    
    private func decodeChatMessageDTO(from dict: [String: Any]) throws -> ChatMessageDTO {
        guard let id = dict["id"] as? String,
              let buyOrNotId = dict["buyOrNotId"] as? String,
              let userId = dict["userId"] as? String,
              let username = dict["username"] as? String,
              let content = dict["content"] as? String,
              let sentDateTime = dict["sentDateTime"] as? String else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Missing required fields in chat message payload"
                )
            )
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
}
