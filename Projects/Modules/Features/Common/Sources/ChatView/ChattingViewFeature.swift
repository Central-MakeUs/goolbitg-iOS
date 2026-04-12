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

        var loadedMessages: [ChatMessageEntity] = []
        var isPaging: Bool = false
        var isInitialLoading: Bool = true
        var isSocketConnected: Bool = false
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
            model: BuyOrNotCardViewEntity
        ) {
            self.userID = userID
            self.userName = userName
            self.model = model
            self.roomId = Int(model.id) ?? 0
        }
    }

    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case showErrorMessage(message: String?)
    }

    public enum ViewCycle {
        case onAppear
        case onDisappear
        case willEnterForeground
    }

    public enum ViewEvent {
        case bindingSendText(String)
        case loadMoreIfNeeded(Int)
        case sendTapped
        case productEditTapped
    }

    public enum FeatureEvent {
        case cachedLoaded([ChatMessageEntity])
        case initialHistoryLoaded([ChatMessageEntity])
        case olderHistoryLoaded([ChatMessageEntity], appendedCount: Int)
        case socketConnectedChanged(Bool)
        case incomingMessagesUpdated([ChatMessageEntity])
        case sendAccepted
        case errorReceived(String)
    }

    private enum CancelID: Hashable {
        case incoming
        case lifecycle
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
                            let connected = await repo.connectSocket(baseURL: baseURL, roomId: roomId)
                            await send(.featureEvent(.socketConnectedChanged(connected)))

                            if connected {
                                for await updated in await repo.incomingMessages(roomId: roomId) {
                                    await send(.featureEvent(.incomingMessagesUpdated(updated)))
                                }
                            } else {
                                await send(.featureEvent(.errorReceived("채팅 서버 연결에 실패했습니다.")))
                            }
                        }
                    }
                    .cancellable(id: CancelID.incoming, cancelInFlight: true),
                    .run { send in
                        let errors = await repo.observeSocketErrors()
                        for await error in errors {
                            await send(.featureEvent(.errorReceived(ChattingViewFeature.socketErrorMessage(from: error))))
                        }
                    }
                    .cancellable(id: CancelID.lifecycle, cancelInFlight: true)
                )

            case .viewCycle(.onDisappear):
                let repo = chatRepository
                return .merge(
                    .run { _ in await repo.disconnectSocket() },
                    .cancel(id: CancelID.incoming),
                    .cancel(id: CancelID.lifecycle)
                )

            case .viewCycle(.willEnterForeground):
                guard !state.isInitialLoading else { return .none }
                let roomId = state.roomId
                let repo = chatRepository
                return .merge(
                    .cancel(id: CancelID.incoming),
                    .cancel(id: CancelID.lifecycle),
                    .run { send in
                        await repo.disconnectSocket()

                        do {
                            let merged = try await repo.fetchLatestHistory(roomId: roomId)
                            await send(.featureEvent(.initialHistoryLoaded(merged)))
                        } catch {
                            await send(.featureEvent(.errorReceived("히스토리 재조회 실패")))
                        }

                        if let baseURL = ChattingViewFeature.socketBaseURL() {
                            let connected = await repo.connectSocket(baseURL: baseURL, roomId: roomId)
                            await send(.featureEvent(.socketConnectedChanged(connected)))
                            if connected {
                                for await updated in await repo.incomingMessages(roomId: roomId) {
                                    await send(.featureEvent(.incomingMessagesUpdated(updated)))
                                }
                            } else {
                                await send(.featureEvent(.errorReceived("채팅 서버 연결에 실패했습니다.")))
                            }
                        }
                    }
                    .cancellable(id: CancelID.incoming, cancelInFlight: true),
                    .run { send in
                        let errors = await repo.observeSocketErrors()
                        for await error in errors {
                            await send(.featureEvent(.errorReceived(ChattingViewFeature.socketErrorMessage(from: error))))
                        }
                    }
                    .cancellable(id: CancelID.lifecycle, cancelInFlight: true)
                )

            case let .featureEvent(.cachedLoaded(cached)):
                if !cached.isEmpty {
                    state.loadedMessages = cached
                }
                return .none

            case let .featureEvent(.initialHistoryLoaded(messages)):
                state.loadedMessages = messages
                state.isInitialLoading = false
                state.hasNextPage = !messages.isEmpty
                return .none

            case let .featureEvent(.olderHistoryLoaded(messages, appendedCount)):
                state.loadedMessages = messages
                state.isPaging = false
                state.hasNextPage = appendedCount > 0
                return .none

            case let .featureEvent(.socketConnectedChanged(connected)):
                state.isSocketConnected = connected
                return .none

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
                let request = ChatSendRequestDTO(
                    userId: state.userID,
                    username: state.userName,
                    content: trimmed
                )
                let repo = chatRepository
                return .run { send in
                    await repo.sendMessage(request)
                    await send(.featureEvent(.sendAccepted))
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

    private static func socketErrorMessage(from error: SocketManager.ManagerError) -> String {
        switch error {
        case .notConfigured:
            return "채팅 소켓 설정이 완료되지 않았습니다."
        case .socketUnavailable:
            return "채팅 소켓을 사용할 수 없습니다."
        case let .invalidEmitPayload(event):
            return "채팅 메시지 형식이 올바르지 않습니다. (\(event))"
        case let .socketError(message):
            return message.isEmpty ? "채팅 소켓 오류가 발생했습니다." : message
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
