//
//  ChattingViewFeature.swift
//  FeatureCommon
//
//  Created by Jae hyung Kim on 3/31/26.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data

@Reducer
public struct ChattingViewFeature: GBReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        let userName: String
        let userID: String
        let model: BuyOrNotCardViewEntity
        let roomId: Int
        public let sessionLease: UUID

        var loadedMessages: [ChatMessageEntity] = []
        var isPaging: Bool = false
        var isInitialLoading: Bool = true
        var isSocketConnected: Bool = false
        var isReconnecting: Bool = false
        var hasNextPage: Bool = true
        var sendText: String = ""
        var product: Product? = nil
        var showErrorMessage: String? = nil

        var listItems: [ChatListItem] {
            ChattingViewFeature.buildListItems(
                from: loadedMessages,
                currentUserId: userID,
                currentUserName: userName
            )
        }

        public init(
            userName: String,
            userID: String,
            model: BuyOrNotCardViewEntity,
            sessionLease: UUID = UUID()
        ) {
            self.userID = userID
            self.userName = userName
            self.model = model
            self.roomId = Int(model.id) ?? 0
            self.sessionLease = sessionLease
        }
    }

    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        case showErrorMessage(message: String?)
    }

    public enum ViewCycle {
        case onAppear
        case onDisappear
        case willEnterForeground
    }

    public enum ViewEvent {
        case backTapped
        case bindingSendText(String)
        case loadMoreIfNeeded(Int)
        case sendTapped
        case productEditTapped
    }

    public enum Delegate {
        case backTapped
    }

    public enum FeatureEvent {
        case cachedLoaded([ChatMessageEntity])
        case initialHistoryLoaded([ChatMessageEntity])
        case olderHistoryLoaded([ChatMessageEntity], appendedCount: Int)
        case socketConnectedChanged(Bool)
        case socketLifecycleReceived(SocketManager.LifecycleEvent)
        case socketErrorReceived(SocketManager.ManagerError)
        case incomingMessagesUpdated([ChatMessageEntity])
        case sendAccepted
        case errorReceived(String)
    }

    private enum CancelID: Hashable {
        case incoming
        case errorStream
        case lifecycleStream
    }

    @Dependency(\.chatRepository) var chatRepository

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                guard state.isInitialLoading else { return .none }
                let item = state.model
                state.product = .init(
                    imageURLString: item.imageUrl,
                    name: item.itemName,
                    priceText: item.priceString,
                    editButtonTitle: "수정"
                )

                let roomId = state.roomId
                let sessionLease = state.sessionLease
                let repo = chatRepository
                return .merge(
                    .run { send in
                        let cached = await repo.loadCachedMessages(roomId: roomId)
                        await send(.featureEvent(.cachedLoaded(cached)))

                        do {
                            let merged = try await repo.fetchLatestHistory(roomId: roomId)
                            await send(.featureEvent(.initialHistoryLoaded(merged)))
                        } catch {
                            await send(.featureEvent(.errorReceived("히스토리 조회 실패")))
                        }

                        if let baseURL = ChattingViewFeature.socketBaseURL() {
                            let connected = await repo.connectSocket(baseURL: baseURL, roomId: roomId, lease: sessionLease)
                            await send(.featureEvent(.socketConnectedChanged(connected)))

                            for await updated in await repo.incomingMessages(roomId: roomId) {
                                await send(.featureEvent(.incomingMessagesUpdated(updated)))
                            }
                        }
                    }
                    .cancellable(id: CancelID.incoming, cancelInFlight: true),
                    .run { send in
                        let errors = await repo.observeSocketErrors()
                        for await error in errors {
                            await send(.featureEvent(.socketErrorReceived(error)))
                        }
                    }
                    .cancellable(id: CancelID.errorStream, cancelInFlight: true),
                    .run { send in
                        let lifecycle = await repo.observeSocketLifecycle()
                        for await event in lifecycle {
                            await send(.featureEvent(.socketLifecycleReceived(event)))
                        }
                    }
                    .cancellable(id: CancelID.lifecycleStream, cancelInFlight: true)
                )

            case .viewCycle(.onDisappear):
                let repo = chatRepository
                let sessionLease = state.sessionLease
                Logger.debug("disconnectSocket Request (child safety net)")
                return .merge(
                    .run { _ in
                        await repo.disconnectSocket(lease: sessionLease)
                    },
                    .cancel(id: CancelID.incoming),
                    .cancel(id: CancelID.errorStream),
                    .cancel(id: CancelID.lifecycleStream)
                )

            case .viewCycle(.willEnterForeground):
                guard !state.isInitialLoading else { return .none }
                let roomId = state.roomId
                let sessionLease = state.sessionLease
                let repo = chatRepository
                return .merge(
                    .cancel(id: CancelID.incoming),
                    .cancel(id: CancelID.errorStream),
                    .cancel(id: CancelID.lifecycleStream),
                    .run { send in
                        await repo.disconnectSocket(lease: sessionLease)

                        do {
                            let merged = try await repo.fetchLatestHistory(roomId: roomId)
                            await send(.featureEvent(.initialHistoryLoaded(merged)))
                        } catch {
                            await send(.featureEvent(.errorReceived("히스토리 재조회 실패")))
                        }

                        if let baseURL = ChattingViewFeature.socketBaseURL() {
                            let connected = await repo.connectSocket(baseURL: baseURL, roomId: roomId, lease: sessionLease)
                            await send(.featureEvent(.socketConnectedChanged(connected)))

                            for await updated in await repo.incomingMessages(roomId: roomId) {
                                await send(.featureEvent(.incomingMessagesUpdated(updated)))
                            }
                        }
                    }
                    .cancellable(id: CancelID.incoming, cancelInFlight: true),
                    .run { send in
                        let errors = await repo.observeSocketErrors()
                        for await error in errors {
                            await send(.featureEvent(.socketErrorReceived(error)))
                        }
                    }
                    .cancellable(id: CancelID.errorStream, cancelInFlight: true),
                    .run { send in
                        let lifecycle = await repo.observeSocketLifecycle()
                        for await event in lifecycle {
                            await send(.featureEvent(.socketLifecycleReceived(event)))
                        }
                    }
                    .cancellable(id: CancelID.lifecycleStream, cancelInFlight: true)
                )

            case let .featureEvent(.cachedLoaded(cached)):
                if !cached.isEmpty {
                    state.loadedMessages = cached
                }
                return .none

            case let .featureEvent(.initialHistoryLoaded(messages)):
                state.loadedMessages = messages
                if state.isInitialLoading {
                    state.hasNextPage = !messages.isEmpty
                }
                state.isInitialLoading = false
                return .none

            case let .featureEvent(.olderHistoryLoaded(messages, appendedCount)):
                state.loadedMessages = messages
                state.isPaging = false
                state.hasNextPage = appendedCount > 0
                return .none

            case let .featureEvent(.socketConnectedChanged(connected)):
                state.isSocketConnected = connected
                if connected {
                    state.isReconnecting = false
                }
                return .none

            case let .featureEvent(.socketLifecycleReceived(event)):
                switch event {
                case .connected:
                    state.isSocketConnected = true
                    state.isReconnecting = false
                    return .none

                case .reconnectAttempt:
                    state.isSocketConnected = false
                    state.isReconnecting = true
                    return .none

                case .reconnect:
                    state.isSocketConnected = true
                    state.isReconnecting = false
                    let roomId = state.roomId
                    let repo = chatRepository
                    return .run { send in
                        do {
                            let merged = try await repo.fetchLatestHistory(roomId: roomId)
                            await send(.featureEvent(.initialHistoryLoaded(merged)))
                        } catch {
                            await send(.featureEvent(.errorReceived("연결 복구 후 메시지를 다시 불러오지 못했습니다.")))
                        }
                    }

                case .disconnected:
                    state.isSocketConnected = false
                    state.isReconnecting = false
                    return .none

                case let .statusChanged(status, _):
                    state.isSocketConnected = status == "connected"
                    if status == "reconnecting" {
                        state.isReconnecting = true
                    } else if status == "connected" || status == "notConnected" {
                        state.isReconnecting = false
                    }
                    return .none
                }

            case let .featureEvent(.socketErrorReceived(error)):
                state.isInitialLoading = false
                guard let message = ChattingViewFeature.socketErrorMessage(from: error, isReconnecting: state.isReconnecting) else {
                    return .none
                }
                return .send(.showErrorMessage(message: message))

            case let .featureEvent(.incomingMessagesUpdated(messages)):
                state.loadedMessages = messages
                return .none

            case .featureEvent(.sendAccepted):
                state.sendText = ""
                return .none

            case let .featureEvent(.errorReceived(message)):
                state.isInitialLoading = false
                return .send(.showErrorMessage(message: message))

            case let .showErrorMessage(message):
                state.showErrorMessage = message
                return .none

            case .delegate:
                return .none

            case .viewEvent(.backTapped):
                return .send(.delegate(.backTapped))

            case let .viewEvent(.bindingSendText(text)):
                state.sendText = text
                return .none

            case let .viewEvent(.loadMoreIfNeeded(index)):
                guard index == 0,
                      state.hasNextPage,
                      !state.isPaging,
                      !state.isInitialLoading else {
                    return .none
                }
                state.isPaging = true
                let roomId = state.roomId
                let previousCount = state.loadedMessages.count
                let repo = chatRepository
                return .run { send in
                    do {
                        let merged = try await repo.fetchOlderHistory(roomId: roomId)
                        let appended = max(0, merged.count - previousCount)
                        await send(.featureEvent(.olderHistoryLoaded(merged, appendedCount: appended)))
                    } catch {
                        await send(.featureEvent(.errorReceived("이전 메시지 로드 실패")))
                    }
                }

            case .viewEvent(.sendTapped):
                let trimmed = state.sendText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return .none }
                guard state.isSocketConnected, !state.isReconnecting else {
                    return .send(.showErrorMessage(message: "채팅 연결을 복구하는 중입니다. 잠시 후 다시 시도해 주세요."))
                }
                let request = ChatSendRequestDTO(
                    userId: state.userID,
                    username: state.userName,
                    content: trimmed
                )
                let repo = chatRepository
                return .run { send in
                    let didSend = await repo.sendMessage(request)
                    if didSend {
                        await send(.featureEvent(.sendAccepted))
                    } else {
                        await send(.featureEvent(.errorReceived("메시지를 보내지 못했습니다. 연결 상태를 확인해 주세요.")))
                    }
                }

            case .viewEvent(.productEditTapped):
                return .none
            }
        }
    }

    private static func socketBaseURL() -> URL? {
        var urlString = ""
        #if DEV
        urlString = "wss://\(SecretKeys.devBase)/chat"
        #else
        urlString = "wss://\(SecretKeys.base)/chat"
        #endif
        Logger.debug(urlString)
        return URL(string: urlString)
    }

    private static func socketErrorMessage(
        from error: SocketManager.ManagerError,
        isReconnecting: Bool
    ) -> String? {
        switch error {
        case .notConfigured:
            return "채팅 소켓 설정이 완료되지 않았습니다."
        case .socketUnavailable:
            return isReconnecting ? nil : "채팅 연결이 일시적으로 끊어졌습니다. 잠시 후 다시 시도해 주세요."
        case let .invalidEmitPayload(event):
            return "채팅 메시지 형식이 올바르지 않습니다. (\(event))"
        case let .socketError(message):
            let normalized = message.lowercased()
            let isTransientDisconnect = normalized.contains("socket is not connected")
                || normalized.contains("socket is not conneted")
                || normalized.contains("network connection was lost")
                || normalized.contains("software caused connection abort")
                || normalized.contains("broken pipe")

            if isTransientDisconnect {
                return isReconnecting ? nil : "채팅 연결이 일시적으로 끊어졌습니다. 다시 연결해 주세요."
            }

            return message.isEmpty ? "채팅 소켓 오류가 발생했습니다." : "채팅 연결에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요."
        }
    }
}

extension ChattingViewFeature {
    struct Product: Equatable, Hashable, Sendable {
        let imageURLString: URL?
        let name: String
        let priceText: String
        let editButtonTitle: String
    }

    struct ChatMessage: Identifiable, Sendable, Equatable, Hashable {
        let id: String
        let dateString: String
        let type: ChatBubbleType
        let text: String
        let timeString: String
        let userName: String?
    }

    enum ChatListItem: Identifiable, Sendable, Equatable, Hashable {
        case date(String)
        case chat(ChatMessage)

        var id: String {
            switch self {
            case let .date(date):
                return "date-\(date)"
            case let .chat(message):
                return "chat-\(message.id)"
            }
        }
    }

    static func buildListItems(
        from entities: [ChatMessageEntity],
        currentUserId: String,
        currentUserName: String
    ) -> [ChatListItem] {
        let messages = entities.map { entity -> ChatMessage in
            let date = entity.sentAt ?? ChatMapper.parseSentDateTime(entity.sentDateTime) ?? Date()
            let dateString = DateManager.shared.format(format: .yyyymmddKorean, date: date)
            let timeString = ChatMapper.koreanTimeString(from: date)
            let isSelf = ChatMapper.isCurrentUserMessage(
                entity,
                currentUserId: currentUserId,
                currentUserName: currentUserName
            )
            return ChatMessage(
                id: String(entity.id),
                dateString: dateString,
                type: isSelf ? .right : .left,
                text: entity.content,
                timeString: timeString,
                userName: isSelf ? nil : entity.username
            )
        }
        return buildListItems(from: messages)
    }

    static func buildListItems(from messages: [ChatMessage]) -> [ChatListItem] {
        var items: [ChatListItem] = []
        var previousDate: String?

        for message in messages {
            if message.dateString != previousDate {
                items.append(.date(message.dateString))
                previousDate = message.dateString
            }
            items.append(.chat(message))
        }

        return items
    }

    static let loadingPlaceholderMessages: [ChatMessage] = [
        .init(
            id: "loading-1",
            dateString: "0000년 00월 00일",
            type: .left,
            text: "                        ",
            timeString: "오전 00:00",
            userName: "로딩중"
        ),
        .init(
            id: "loading-2",
            dateString: "0000년 00월 00일",
            type: .right,
            text: "                    ",
            timeString: "오전 00:00",
            userName: nil
        ),
        .init(
            id: "loading-3",
            dateString: "0000년 00월 00일",
            type: .left,
            text: "                           ",
            timeString: "오전 00:00",
            userName: "로딩중"
        )
    ]
}
