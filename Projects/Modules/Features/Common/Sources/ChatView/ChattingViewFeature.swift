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
        
        var loadedPageCount: Int = 0
        var isPaging: Bool = false
        var isInitialLoading: Bool = true
        var sendText: String = ""
        var product: Product? = nil
        
        var hasNextPage: Bool {
            return false
        }
        
        var loadedMessages: [ChatMessage] {
            return []
        }
        
        var listItems: [ChatListItem] {
            ChattingViewFeature.buildListItems(from: loadedMessages)
        }
        
        public init(
            userName: String,
            userID: String,
            model: BuyOrNotCardViewEntity,
        ) {
            self.userID = userID
            self.userName = userName
            self.model = model
        }
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum ViewEvent {
        case bindingSendText(String)
        case loadMoreIfNeeded(Int)
        case sendTapped
        case productEditTapped
    }
    
    public enum FeatureEvent {
        case initialLoadCompleted
        case paginationCompleted
    }
    
    private enum CancelID {
        static let initialLoading = "ChattingViewFeature.initialLoading"
        static let paging = "ChattingViewFeature.paging"
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                guard state.isInitialLoading else {
                    return .none
                }
                
                let item = state.model
                
                state.product = .init(
                    imageURLString: item.imageUrl,
                    name: item.itemName,
                    priceText: item.priceString,
                    editButtonTitle: "수정",
                )
                
                return .run { send in
                    try await Task.sleep(for: .milliseconds(650))
                    await send(.featureEvent(.initialLoadCompleted))
                }
                .cancellable(id: CancelID.initialLoading)
                
            case .featureEvent(.initialLoadCompleted):
                state.isInitialLoading = false
                state.loadedPageCount = 1
                return .none
                
            case let .viewEvent(.bindingSendText(text)):
                state.sendText = text
                return .none
                
            case let .viewEvent(.loadMoreIfNeeded(index)):
                guard index == 0, state.hasNextPage, !state.isPaging, !state.isInitialLoading else {
                    return .none
                }
                
                state.isPaging = true
                
                return .run { send in
                    try await Task.sleep(for: .milliseconds(350))
                    await send(.featureEvent(.paginationCompleted))
                }
                .cancellable(id: CancelID.paging)
                
            case .viewEvent(.sendTapped):
                state.sendText = ""
                return .none
                
            
                
            case .viewEvent(.productEditTapped):
                return .none
                
            case .featureEvent(.paginationCompleted):
                state.loadedPageCount += 1
                state.isPaging = false
                return .none
            }
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
    
    struct ChatMessage: Identifiable, Sendable {
        let id: String
        let dateString: String
        let type: ChatBubbleType
        let text: String
        let timeString: String
        let userName: String?
    }
    
    enum ChatListItem: Identifiable, Sendable {
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
