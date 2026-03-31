//
//  ChattingViewFeature.swift
//  FeatureBuyOrNot
//
//  Created by Jae hyung Kim on 3/31/26.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain

@Reducer
public struct ChattingViewFeature: GBReducer {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Hashable {
        var loadedPageCount: Int = 0
        var isPaging: Bool = false
        var isInitialLoading: Bool = true
        var sendText: String = ""
        
        var roomTitle: String = "바쁜굴비님의 토론방"
        var product: Product = .init(
            imageURLString: "https://image.msscdn.net/thumbnails/images/goods_img/20250903/5397926/5397926_17582584972271_big.jpg?w=1200",
            name: "테켓 후드티",
            priceText: "89,000원",
            editButtonTitle: "수정"
        )
        
        var hasNextPage: Bool {
            loadedPageCount < ChattingViewFeature.dummyPages.count
        }
        
        var loadedMessages: [ChatMessage] {
            let pages = ChattingViewFeature.dummyPages.suffix(loadedPageCount)
            return pages.flatMap { $0 }
        }
        
        var listItems: [ChatListItem] {
            ChattingViewFeature.buildListItems(from: loadedMessages)
        }
        
        public init() {}
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
        case backTapped
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
                
            case .viewEvent(.backTapped):
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
        let imageURLString: String
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
    
    static let dummyPages: [[ChatMessage]] = [
        [
            .init(
                id: "p1-1",
                dateString: "2024년 12월 13일",
                type: .left,
                text: "지금 네이버 쇼핑에서 파는게 더 저렴함 https://smartstore.naver.com/",
                timeString: "오전 11:38",
                userName: "거지굴비"
            ),
            .init(
                id: "p1-2",
                dateString: "2024년 12월 13일",
                type: .right,
                text: "오 좋은 정보 감사합니다 :D",
                timeString: "오전 11:40",
                userName: nil
            ),
            .init(
                id: "p1-3",
                dateString: "2024년 12월 13일",
                type: .left,
                text: "장바구니 담아두고 밤 12시 쿠폰도 확인해보세요.",
                timeString: "오전 11:42",
                userName: "거지굴비"
            )
        ],
        [
            .init(
                id: "p2-1",
                dateString: "2024년 12월 14일",
                type: .left,
                text: "어제보다 배송비가 줄었네요.",
                timeString: "오후 9:20",
                userName: "절약굴비"
            ),
            .init(
                id: "p2-2",
                dateString: "2024년 12월 14일",
                type: .right,
                text: "그럼 총액이 8만 후반대로 내려가요?",
                timeString: "오후 9:22",
                userName: nil
            ),
            .init(
                id: "p2-3",
                dateString: "2024년 12월 14일",
                type: .left,
                text: "네 맞아요. 내일 카드할인도 붙을 수 있어요.",
                timeString: "오후 9:23",
                userName: "절약굴비"
            )
        ],
        [
            .init(
                id: "p3-1",
                dateString: "2024년 12월 15일",
                type: .left,
                text: "오늘 가격 다시 확인해보니 2천원 내려갔어요.",
                timeString: "오전 11:04",
                userName: "바쁜굴비"
            ),
            .init(
                id: "p3-2",
                dateString: "2024년 12월 15일",
                type: .right,
                text: "오 감사합니다! 그럼 지금 사는게 낫겠네요.",
                timeString: "오전 11:08",
                userName: nil
            ),
            .init(
                id: "p3-3",
                dateString: "2024년 12월 15일",
                type: .left,
                text: "네, 쿠폰 적용하면 체감가 더 좋아요.",
                timeString: "오전 11:09",
                userName: "바쁜굴비"
            )
        ]
    ]
}
