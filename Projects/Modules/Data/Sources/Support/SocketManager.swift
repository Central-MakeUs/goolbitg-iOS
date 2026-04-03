//
//  SocketManager.swift
//  Data
//
//  Created by Jae hyung Kim on 4/3/26.
//

import Foundation
#if canImport(SocketIO)
import SocketIO
#endif

#if canImport(ComposableArchitecture)
import ComposableArchitecture
#endif

/// Socket 통신 수명주기 전담 매니저
/// - 중요: URL/프로토콜/이벤트 스키마는 외부에서 주입합니다.
/// - 목적: 연결, 재연결, 리스너 관리, 스트림 발행을 안정적으로 관리합니다.
public actor SocketManager {

    // MARK: - Types

    /// 외부에서 주입하는 연결 설정
    public struct Configuration {
        public let url: URL
#if canImport(SocketIO)
        public var options: SocketIOClientConfiguration

        public init(url: URL, options: SocketIOClientConfiguration = []) {
            self.url = url
            self.options = options
        }
#else
        public init(url: URL) {
            self.url = url
        }
#endif
    }

    /// 매니저가 바깥으로 전달하는 raw 이벤트 모델
    /// - 프로토콜/DTO 매핑은 상위 계층에서 처리
    public struct Event {
        public let name: String
        public let items: [Any]

        public init(name: String, items: [Any]) {
            self.name = name
            self.items = items
        }
    }

    /// 소켓 라이프사이클 이벤트
    public enum LifecycleEvent {
        case connected(items: [Any])
        case disconnected(reason: String, items: [Any])
        case reconnect(items: [Any])
        case reconnectAttempt(items: [Any])
        case statusChanged(status: String, items: [Any])
    }

    /// 매니저 레벨 에러
    public enum ManagerError: Error {
        case notConfigured
        case socketUnavailable
        case invalidEmitPayload(event: String)
        case socketError(message: String)
    }

    /// 개별 listen(event:) 구독 엔트리
    /// - handlerID는 Socket.IO 핸들러 해제 시 사용
    private struct EventListenerEntry {
        let eventName: String
        let handlerID: UUID
        let continuation: AsyncStream<Event>.Continuation
    }

    // MARK: - State

    private var configuration: Configuration?
    /// socket 교체 시 generation을 증가시켜 이전 소켓 콜백을 무시합니다.
    private var connectionGeneration: Int = 0

#if canImport(SocketIO)
    private var manager: SocketIO.SocketManager?
    private var socket: SocketIOClient?
#endif

    /// observeEvents() 구독자 집합
    private var eventContinuations: [UUID: AsyncStream<Event>.Continuation] = [:]
    /// observeErrors() 구독자 집합
    private var errorContinuations: [UUID: AsyncStream<ManagerError>.Continuation] = [:]
    /// observeLifecycle() 구독자 집합
    private var lifecycleContinuations: [UUID: AsyncStream<LifecycleEvent>.Continuation] = [:]
    /// listen(event:) 구독자 집합
    private var eventListeners: [UUID: EventListenerEntry] = [:]

    /// actor 생성 후 configure/connect는 외부 호출로 수행합니다.
    public init() {}

    deinit {
        // deinit은 await 불가이므로 socket 정리만 즉시 수행합니다.
#if canImport(SocketIO)
        socket?.removeAllHandlers()
        socket?.disconnect()
#endif
    }
}

// MARK: - Public APIs
extension SocketManager {

    /// 소켓 상태 문자열
    public var status: String {
#if canImport(SocketIO)
        String(describing: socket?.status ?? SocketIOStatus.notConnected)
#else
        "notConnected"
#endif
    }

    /// 설정만 교체
    /// - 핵심: 기존 listen 스트림은 끊지 않고 새 socket에 재바인딩합니다.
    public func configure(_ configuration: Configuration) {
#if canImport(SocketIO)
        let previousSocket = socket
        let previousListeners = eventListeners
        connectionGeneration += 1
        let generation = connectionGeneration

        self.configuration = configuration
        let newManager = SocketIO.SocketManager(socketURL: configuration.url, config: configuration.options)
        let newSocket = newManager.defaultSocket

        manager = newManager
        socket = newSocket
        eventListeners.removeAll()

        previousSocket?.removeAllHandlers()
        previousSocket?.disconnect()

        registerLifecycleHandlers(generation: generation)
        registerGlobalEventForwarder(generation: generation)
        rebindListeners(previousListeners, generation: generation)
#else
        self.configuration = configuration
        publishError(.socketUnavailable)
#endif
    }

#if canImport(SocketIO)
    /// URL + options를 바로 받아 connect까지 수행
    public func connect(url: URL, options: SocketIOClientConfiguration = []) {
        configure(.init(url: url, options: options))
        connect()
    }
#else
    public func connect(url: URL) {
        configure(.init(url: url))
        connect()
    }
#endif

    /// configure 이후 연결 시작
    public func connect() {
#if canImport(SocketIO)
        guard let socket else {
            publishError(.notConfigured)
            return
        }
        socket.connect()
#else
        publishError(.socketUnavailable)
#endif
    }

    /// 연결 종료 (스트림은 유지)
    public func disconnect() {
#if canImport(SocketIO)
        socket?.disconnect()
#endif
    }

    /// 일반 emit
    public func emit(event: String, items: [Any] = []) {
#if canImport(SocketIO)
        guard let socket else {
            publishError(.notConfigured)
            return
        }

        let socketItems = items.compactMap { $0 as? SocketData }
        guard socketItems.count == items.count else {
            publishError(.invalidEmitPayload(event: event))
            return
        }

        socket.emit(event, with: socketItems, completion: nil)
#else
        _ = event
        _ = items
        publishError(.socketUnavailable)
#endif
    }

    /// ack 기반 emit
    public func emitWithAck(
        event: String,
        items: [Any] = [],
        timeout: Double = 0,
        callback: @escaping ([Any]) -> Void
    ) {
#if canImport(SocketIO)
        guard let socket else {
            publishError(.notConfigured)
            return
        }

        let socketItems = items.compactMap { $0 as? SocketData }
        guard socketItems.count == items.count else {
            publishError(.invalidEmitPayload(event: event))
            return
        }

        socket.emitWithAck(event, with: socketItems)
            .timingOut(after: timeout) { values in
                callback(values)
            }
#else
        _ = event
        _ = items
        _ = timeout
        callback([])
        publishError(.socketUnavailable)
#endif
    }

    /// 특정 이벤트를 직접 구독
    /// - 이 스트림은 해당 이벤트에만 반응합니다.
    public func listen(event: String) -> AsyncStream<Event> {
        AsyncStream<Event>(bufferingPolicy: .unbounded) { continuation in
#if canImport(SocketIO)
            guard let socket else {
                publishError(.notConfigured)
                continuation.finish()
                return
            }

            let generation = connectionGeneration

            let listenerID = UUID()
            let handlerID = socket.on(event) { data, _ in
                Task { [weak self] in
                    await self?.yieldEventIfCurrent(
                        generation: generation,
                        continuation: continuation,
                        eventName: event,
                        items: data
                    )
                }
            }

            eventListeners[listenerID] = EventListenerEntry(
                eventName: event,
                handlerID: handlerID,
                continuation: continuation
            )

            continuation.onTermination = { @Sendable [weak self] _ in
                Task {
                    await self?.removeListener(id: listenerID)
                }
            }
#else
            _ = event
            publishError(.socketUnavailable)
            continuation.finish()
#endif
        }
    }

    /// 전체 이벤트 스트림 (onAny 기반 단일 발행)
    public func observeEvents() -> AsyncStream<Event> {
        AsyncStream<Event>(bufferingPolicy: .unbounded) { continuation in
            let id = UUID()
            eventContinuations[id] = continuation

            continuation.onTermination = { @Sendable [weak self] _ in
                Task {
                    await self?.removeEventContinuation(id: id)
                }
            }
        }
    }

    /// 매니저 에러 스트림
    public func observeErrors() -> AsyncStream<ManagerError> {
        AsyncStream<ManagerError>(bufferingPolicy: .unbounded) { continuation in
            let id = UUID()
            errorContinuations[id] = continuation

            continuation.onTermination = { @Sendable [weak self] _ in
                Task {
                    await self?.removeErrorContinuation(id: id)
                }
            }
        }
    }

    /// lifecycle 스트림
    public func observeLifecycle() -> AsyncStream<LifecycleEvent> {
        AsyncStream<LifecycleEvent>(bufferingPolicy: .unbounded) { continuation in
            let id = UUID()
            lifecycleContinuations[id] = continuation

            continuation.onTermination = { @Sendable [weak self] _ in
                Task {
                    await self?.removeLifecycleContinuation(id: id)
                }
            }
        }
    }

    /// 매니저 전체 초기화
    /// - socket/handler/스트림을 모두 정리합니다.
    public func reset() {
#if canImport(SocketIO)
        let currentSocket = socket
        let listeners = Array(eventListeners.values)
        let events = Array(eventContinuations.values)
        let errors = Array(errorContinuations.values)
        let lifecycles = Array(lifecycleContinuations.values)

        socket = nil
        manager = nil
        configuration = nil
        eventListeners.removeAll()
        eventContinuations.removeAll()
        errorContinuations.removeAll()
        lifecycleContinuations.removeAll()

        listeners.forEach {
            currentSocket?.off(id: $0.handlerID)
            $0.continuation.finish()
        }

        currentSocket?.removeAllHandlers()
        currentSocket?.disconnect()
        events.forEach { $0.finish() }
        errors.forEach { $0.finish() }
        lifecycles.forEach { $0.finish() }
#else
        let events = Array(eventContinuations.values)
        let errors = Array(errorContinuations.values)
        let lifecycles = Array(lifecycleContinuations.values)

        configuration = nil
        eventListeners.removeAll()
        eventContinuations.removeAll()
        errorContinuations.removeAll()
        lifecycleContinuations.removeAll()

        events.forEach { $0.finish() }
        errors.forEach { $0.finish() }
        lifecycles.forEach { $0.finish() }
#endif
    }
}

// MARK: - Internal Helpers
private extension SocketManager {
#if canImport(SocketIO)
    /// 소켓 라이프사이클 이벤트를 observeLifecycle()로 전달
    func registerLifecycleHandlers(generation: Int) {
        guard let socket else { return }

        socket.on(clientEvent: .connect) { [weak self] data, _ in
            Task { await self?.publishLifecycleIfCurrent(generation: generation, .connected(items: data)) }
        }

        socket.on(clientEvent: .disconnect) { [weak self] data, _ in
            let reason = data.first.map { String(describing: $0) } ?? "unknown"
            Task { await self?.publishLifecycleIfCurrent(generation: generation, .disconnected(reason: reason, items: data)) }
        }

        socket.on(clientEvent: .reconnect) { [weak self] data, _ in
            Task { await self?.publishLifecycleIfCurrent(generation: generation, .reconnect(items: data)) }
        }

        socket.on(clientEvent: .reconnectAttempt) { [weak self] data, _ in
            Task { await self?.publishLifecycleIfCurrent(generation: generation, .reconnectAttempt(items: data)) }
        }

        socket.on(clientEvent: .statusChange) { [weak self] data, _ in
            let status = (data.first as? String) ?? String(describing: socket.status)
            Task { await self?.publishLifecycleIfCurrent(generation: generation, .statusChanged(status: status, items: data)) }
        }

        socket.on(clientEvent: .error) { [weak self] data, _ in
            let message = data.first.map { String(describing: $0) } ?? "Unknown socket error"
            Task { await self?.publishErrorIfCurrent(generation: generation, .socketError(message: message)) }
        }
    }

    /// onAny를 통해 global event stream을 단일 경로로 발행
    /// - listen(event:)에서 중복 발행하지 않으므로 observeEvents() 중복 문제를 줄입니다.
    func registerGlobalEventForwarder(generation: Int) {
        guard let socket else { return }

        socket.onAny { [weak self] anyEvent in
            Task {
                await self?.publishEventIfCurrent(
                    generation: generation,
                    Event(name: anyEvent.event, items: anyEvent.items ?? [])
                )
            }
        }
    }

    /// 기존 listen 스트림을 새 socket에 재바인딩
    /// - configure 시 스트림 단절 없이 handler만 교체합니다.
    private func rebindListeners(_ listeners: [UUID: EventListenerEntry], generation: Int) {
        guard let socket else { return }

        for (listenerID, oldEntry) in listeners {
            let newHandlerID = socket.on(oldEntry.eventName) { data, _ in
                Task { [weak self] in
                    await self?.yieldEventIfCurrent(
                        generation: generation,
                        continuation: oldEntry.continuation,
                        eventName: oldEntry.eventName,
                        items: data
                    )
                }
            }

            eventListeners[listenerID] = EventListenerEntry(
                eventName: oldEntry.eventName,
                handlerID: newHandlerID,
                continuation: oldEntry.continuation
            )
        }
    }

    /// listen(event:) 개별 구독 해제
    func removeListener(id: UUID) {
        guard let entry = eventListeners.removeValue(forKey: id) else { return }
        socket?.off(id: entry.handlerID)
        entry.continuation.finish()
    }
#endif

    func removeEventContinuation(id: UUID) {
        eventContinuations.removeValue(forKey: id)
    }

    func removeErrorContinuation(id: UUID) {
        errorContinuations.removeValue(forKey: id)
    }

    func removeLifecycleContinuation(id: UUID) {
        lifecycleContinuations.removeValue(forKey: id)
    }

    /// generation이 현재 소켓과 다르면 이전 소켓에서 온 콜백으로 간주하고 무시
    func publishEventIfCurrent(generation: Int, _ event: Event) {
        guard generation == connectionGeneration else { return }
        publishEvent(event)
    }

    /// generation이 현재 소켓과 다르면 이전 소켓에서 온 콜백으로 간주하고 무시
    func publishErrorIfCurrent(generation: Int, _ error: ManagerError) {
        guard generation == connectionGeneration else { return }
        publishError(error)
    }

    /// generation이 현재 소켓과 다르면 이전 소켓에서 온 콜백으로 간주하고 무시
    func publishLifecycleIfCurrent(generation: Int, _ lifecycleEvent: LifecycleEvent) {
        guard generation == connectionGeneration else { return }
        publishLifecycle(lifecycleEvent)
    }

    /// listen(event:) 직접 구독 스트림도 generation 체크로 stale 콜백을 차단
    func yieldEventIfCurrent(
        generation: Int,
        continuation: AsyncStream<Event>.Continuation,
        eventName: String,
        items: [Any]
    ) {
        guard generation == connectionGeneration else { return }
        continuation.yield(Event(name: eventName, items: items))
    }

    func publishEvent(_ event: Event) {
        eventContinuations.values.forEach { $0.yield(event) }
    }

    func publishError(_ error: ManagerError) {
        errorContinuations.values.forEach { $0.yield(error) }
    }

    func publishLifecycle(_ lifecycleEvent: LifecycleEvent) {
        lifecycleContinuations.values.forEach { $0.yield(lifecycleEvent) }
    }
}

// MARK: - Dependency
extension SocketManager {
    /// Socket은 상태를 가지는 long-lived 자원이라 공유 인스턴스를 사용합니다.
    public static let shared = SocketManager()
}

#if canImport(ComposableArchitecture)
extension SocketManager: DependencyKey {
    public static let liveValue: SocketManager = .shared
}

extension DependencyValues {
    public var socketManager: SocketManager {
        get { self[SocketManager.self] }
        set { self[SocketManager.self] = newValue }
    }
}
#endif
