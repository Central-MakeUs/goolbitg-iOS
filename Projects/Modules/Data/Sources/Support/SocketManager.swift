import Foundation

#if canImport(ComposableArchitecture)
import ComposableArchitecture
#endif

struct STOMPFrame: Equatable, Sendable {
    let command: String
    let headers: [String: String]
    let body: String

    init(command: String, headers: [String: String] = [:], body: String = "") {
        self.command = command
        self.headers = headers
        self.body = body
    }
}

enum STOMPFrameCodec {
    static func serialize(_ frame: STOMPFrame) -> String {
        var lines = [frame.command]
        for key in frame.headers.keys.sorted() {
            guard let value = frame.headers[key] else { continue }
            lines.append("\(key):\(value)")
        }
        lines.append("")
        return lines.joined(separator: "\n") + "\n" + frame.body + "\u{0000}"
    }

    static func deserialize(_ raw: String) -> [STOMPFrame] {
        raw
            .split(separator: "\u{0000}", omittingEmptySubsequences: true)
            .compactMap { parseSingleFrame(String($0)) }
    }

    static func jsonObject(from body: String) -> Any? {
        guard let data = body.data(using: .utf8), !data.isEmpty else { return nil }
        return try? JSONSerialization.jsonObject(with: data)
    }

    static func jsonString(from object: Any) -> String? {
        guard JSONSerialization.isValidJSONObject(object) else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: object) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func parseSingleFrame(_ rawFrame: String) -> STOMPFrame? {
        let trimmed = rawFrame.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalized = rawFrame.replacingOccurrences(of: "\r\n", with: "\n")
        let separator = "\n\n"

        let headerSection: String
        let bodySection: String
        if let range = normalized.range(of: separator) {
            headerSection = String(normalized[..<range.lowerBound])
            bodySection = String(normalized[range.upperBound...])
        } else {
            headerSection = normalized
            bodySection = ""
        }

        let headerLines = headerSection.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard let commandLine = headerLines.first?.trimmingCharacters(in: .whitespacesAndNewlines), !commandLine.isEmpty else {
            return nil
        }

        var headers: [String: String] = [:]
        for line in headerLines.dropFirst() where !line.isEmpty {
            guard let separatorIndex = line.firstIndex(of: ":") else { continue }
            let key = String(line[..<separatorIndex])
            let value = String(line[line.index(after: separatorIndex)...])
            headers[key] = value
        }

        return STOMPFrame(command: commandLine, headers: headers, body: bodySection)
    }
}

public actor SocketManager {

    public struct Configuration {
        public let url: URL

        public init(url: URL) {
            self.url = url
        }
    }

    public struct Event {
        public let name: String
        public let items: [Any]

        public init(name: String, items: [Any]) {
            self.name = name
            self.items = items
        }
    }

    public enum LifecycleEvent {
        case connected(items: [Any])
        case disconnected(reason: String, items: [Any])
        case reconnect(items: [Any])
        case reconnectAttempt(items: [Any])
        case statusChanged(status: String, items: [Any])
    }

    public enum ManagerError: Error {
        case notConfigured
        case socketUnavailable
        case invalidEmitPayload(event: String)
        case socketError(message: String)
    }

    private struct EventListenerEntry {
        let eventName: String
        let continuation: AsyncStream<Event>.Continuation
    }

    private var configuration: Configuration?
    private var connectionGeneration: Int = 0
    private var statusValue: String = "notConnected"
    private var socketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var receiveTask: Task<Void, Never>?
    private var desiredSubscriptions: Set<String> = []
    private var activeSubscriptions: Set<String> = []

    private var eventContinuations: [UUID: AsyncStream<Event>.Continuation] = [:]
    private var errorContinuations: [UUID: AsyncStream<ManagerError>.Continuation] = [:]
    private var lifecycleContinuations: [UUID: AsyncStream<LifecycleEvent>.Continuation] = [:]
    private var eventListeners: [UUID: EventListenerEntry] = [:]

    public init() {}

    deinit {
        receiveTask?.cancel()
        socketTask?.cancel(with: .goingAway, reason: nil)
        session?.invalidateAndCancel()
    }
}

extension SocketManager {
    public var status: String {
        statusValue
    }

    public func configure(_ configuration: Configuration) {
        self.configuration = configuration
        connectionGeneration += 1
        activeSubscriptions.removeAll()
        publishLifecycle(.statusChanged(status: "configured", items: []))
    }

    public func connect(url: URL) async {
        configure(.init(url: url))
        await connect()
    }

    public func connect() async {
        guard let configuration else {
            publishError(.notConfigured)
            return
        }

        await tearDownConnection(reason: nil, incrementGeneration: false)
        let generation = connectionGeneration

        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: configuration.url)
        self.session = session
        self.socketTask = task
        self.statusValue = "connecting"
        publishLifecycle(.statusChanged(status: "connecting", items: []))

        task.resume()

        var headers = [
            "accept-version": "1.2",
            "heart-beat": "0,0"
        ]
        if let host = configuration.url.host, !host.isEmpty {
            headers["host"] = host
        }

        do {
            try await send(frame: STOMPFrame(command: "CONNECT", headers: headers))
            receiveTask = Task { [weak self] in
                await self?.receiveLoop(generation: generation)
            }
        } catch {
            publishError(.socketError(message: error.localizedDescription))
        }
    }

    public func disconnect() async {
        await tearDownConnection(reason: "client disconnect", incrementGeneration: true)
    }

    public func emit(event: String, items: [Any] = []) async {
        guard let payload = items.first else {
            publishError(.invalidEmitPayload(event: event))
            return
        }
        guard let body = STOMPFrameCodec.jsonString(from: payload) else {
            publishError(.invalidEmitPayload(event: event))
            return
        }

        do {
            try await send(frame: STOMPFrame(
                command: "SEND",
                headers: [
                    "destination": event,
                    "content-type": "application/json"
                ],
                body: body
            ))
        } catch {
            publishError(.socketError(message: error.localizedDescription))
        }
    }

    public func emitWithAck(
        event: String,
        items: [Any] = [],
        timeout: Double = 0,
        callback: @escaping ([Any]) -> Void
    ) async {
        await emit(event: event, items: items)
        let result: [Any] = timeout >= 0 ? [] : []
        callback(result)
    }

    public func listen(event: String) -> AsyncStream<Event> {
        AsyncStream<Event>(bufferingPolicy: .unbounded) { continuation in
            let listenerID = UUID()
            eventListeners[listenerID] = EventListenerEntry(eventName: event, continuation: continuation)
            desiredSubscriptions.insert(event)

            Task {
                await activateSubscriptionIfNeeded(event: event)
            }

            continuation.onTermination = { @Sendable [weak self] _ in
                Task {
                    await self?.removeListener(id: listenerID)
                }
            }
        }
    }

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

    public func reset() async {
        await tearDownConnection(reason: "reset", incrementGeneration: true)

        let events = Array(eventContinuations.values)
        let errors = Array(errorContinuations.values)
        let lifecycles = Array(lifecycleContinuations.values)
        let listeners = Array(eventListeners.values)

        configuration = nil
        desiredSubscriptions.removeAll()
        activeSubscriptions.removeAll()
        eventListeners.removeAll()
        eventContinuations.removeAll()
        errorContinuations.removeAll()
        lifecycleContinuations.removeAll()

        listeners.forEach { $0.continuation.finish() }
        events.forEach { $0.finish() }
        errors.forEach { $0.finish() }
        lifecycles.forEach { $0.finish() }
    }
}

private extension SocketManager {
    var isSocketConnected: Bool {
        statusValue == "connected"
    }

    func send(frame: STOMPFrame) async throws {
        guard let socketTask else {
            throw ManagerError.notConfigured
        }
        try await socketTask.send(.string(STOMPFrameCodec.serialize(frame)))
    }

    func receiveLoop(generation: Int) async {
        guard let socketTask else { return }

        do {
            while !Task.isCancelled {
                let message = try await socketTask.receive()
                guard generation == connectionGeneration else { return }

                switch message {
                case let .string(text):
                    await handleIncoming(rawMessage: text)
                case let .data(data):
                    if let text = String(data: data, encoding: .utf8) {
                        await handleIncoming(rawMessage: text)
                    } else {
                        publishError(.socketError(message: "Unable to decode WebSocket data message"))
                    }
                @unknown default:
                    publishError(.socketError(message: "Unknown WebSocket message type"))
                }
            }
        } catch {
            guard generation == connectionGeneration else { return }
            await tearDownConnection(reason: error.localizedDescription, incrementGeneration: false)
            publishError(.socketError(message: error.localizedDescription))
        }
    }

    func handleIncoming(rawMessage: String) async {
        let frames = STOMPFrameCodec.deserialize(rawMessage)

        for frame in frames {
            switch frame.command {
            case "CONNECTED":
                statusValue = "connected"
                publishLifecycle(.connected(items: [frame.headers]))
                publishLifecycle(.statusChanged(status: "connected", items: []))
                for destination in desiredSubscriptions.sorted() {
                    await activateSubscriptionIfNeeded(event: destination)
                }

            case "MESSAGE":
                let destination = frame.headers["destination"] ?? ""
                let payload = STOMPFrameCodec.jsonObject(from: frame.body)
                let items = payload.map { [$0] } ?? [frame.body]
                let event = Event(name: destination, items: items)
                publishEvent(event)
                yieldToMatchingListeners(event)

            case "ERROR":
                let message = frame.body.isEmpty ? (frame.headers["message"] ?? "Unknown STOMP error") : frame.body
                publishError(.socketError(message: message))

            case "RECEIPT":
                continue

            default:
                continue
            }
        }
    }

    func activateSubscriptionIfNeeded(event: String) async {
        guard isSocketConnected, !activeSubscriptions.contains(event) else { return }
        do {
            try await send(frame: STOMPFrame(
                command: "SUBSCRIBE",
                headers: [
                    "id": subscriptionID(for: event),
                    "destination": event
                ]
            ))
            activeSubscriptions.insert(event)
        } catch {
            publishError(.socketError(message: error.localizedDescription))
        }
    }

    func deactivateSubscriptionIfNeeded(event: String) async {
        guard activeSubscriptions.contains(event) else { return }
        do {
            try await send(frame: STOMPFrame(
                command: "UNSUBSCRIBE",
                headers: ["id": subscriptionID(for: event)]
            ))
        } catch {
            publishError(.socketError(message: error.localizedDescription))
        }
        activeSubscriptions.remove(event)
    }

    func tearDownConnection(reason: String?, incrementGeneration: Bool) async {
        if incrementGeneration {
            connectionGeneration += 1
        }

        receiveTask?.cancel()
        receiveTask = nil

        socketTask?.cancel(with: .goingAway, reason: nil)
        socketTask = nil

        session?.invalidateAndCancel()
        session = nil

        activeSubscriptions.removeAll()

        let wasConnected = statusValue == "connected" || statusValue == "connecting"
        statusValue = "notConnected"

        if let reason, wasConnected {
            publishLifecycle(.disconnected(reason: reason, items: []))
        }
        publishLifecycle(.statusChanged(status: "notConnected", items: []))
    }

    func removeListener(id: UUID) async {
        guard let entry = eventListeners.removeValue(forKey: id) else { return }
        entry.continuation.finish()

        let stillNeedsSubscription = eventListeners.values.contains { $0.eventName == entry.eventName }
        if !stillNeedsSubscription {
            desiredSubscriptions.remove(entry.eventName)
            await deactivateSubscriptionIfNeeded(event: entry.eventName)
        }
    }

    func subscriptionID(for event: String) -> String {
        "sub-\(event.replacingOccurrences(of: "/", with: "-"))"
    }

    func yieldToMatchingListeners(_ event: Event) {
        for listener in eventListeners.values where listener.eventName == event.name {
            listener.continuation.yield(event)
        }
    }

    func removeEventContinuation(id: UUID) {
        eventContinuations.removeValue(forKey: id)
    }

    func removeErrorContinuation(id: UUID) {
        errorContinuations.removeValue(forKey: id)
    }

    func removeLifecycleContinuation(id: UUID) {
        lifecycleContinuations.removeValue(forKey: id)
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

extension SocketManager {
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
