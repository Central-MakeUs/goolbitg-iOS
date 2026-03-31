//
//  ChattingView.swift
//  FeatureBuyOrNot
//
//  Created by Jae hyung Kim on 3/31/26.
//

import SwiftUI
import ComposableArchitecture
import Utils
import FeatureCommon

struct ChattingView: View {
    @State private var loadedPageCount: Int = 1
    @State private var isPaging: Bool = false
    @State private var sendText: String = ""
    
    private var hasNextPage: Bool {
        loadedPageCount < Self.dummyPages.count
    }
    
    private var loadedMessages: [ChatMessage] {
        let pages = Self.dummyPages.suffix(loadedPageCount)
        return pages.flatMap { $0 }
    }
    
    private var listItems: [ChatListItem] {
        Self.buildListItems(from: loadedMessages)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.horizontal, .md)
                .padding(.vertical, .md)
            
            productSection
                .padding(.bottom, 20)
            
            listSection
                .resetListStyle()
            
            textInputSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoreAreaBackgroundColor(GBColor.background1.asColor)
    }
    
    private var listSection: some View {
        List {
            if isPaging {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .sm)
                    .resetRowStyle()
                    .listRowBackground(Color.clear)
            }
            
            ForEach(Array(listItems.enumerated()), id: \.element.id) { index, item in
                switch item {
                case let .date(dateString):
                    dateSection(dateString: dateString)
                        .padding(.bottom, .lg)
                        .resetRowStyle()
                        .listRowBackground(Color.clear)
                        .onAppear {
                            loadMoreIfNeeded(currentIndex: index)
                        }
                        
                        
                case let .chat(message):
                    ChatBubbleView(
                        type: message.type,
                        text: message.text,
                        timeStr: message.timeString,
                        userName: message.userName
                    )
                    .padding(.horizontal, .sm)
                    .padding(.bottom, .lg)
                    .resetRowStyle()
                    .listRowBackground(Color.clear)
                    .onAppear {
                        loadMoreIfNeeded(currentIndex: index)
                    }
                }
            }
        }
    }
    
    private func dateSection(dateString: String) -> some View {
        return HStack {
            GBColor.grey400.asColor
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            
            Text(dateString)
                .font(FontHelper.body4.font)
                .foregroundStyle(GBColor.grey400.asColor)
            
            GBColor.grey400.asColor
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, .md)
    }
    
    private func loadMoreIfNeeded(currentIndex: Int) {
        guard currentIndex == 0, hasNextPage, !isPaging else {
            return
        }
        
        isPaging = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            loadedPageCount += 1
            isPaging = false
        }
    }
}

private extension ChattingView {
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
    
    static let dummyPages: [[ChatMessage]] = [
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
        ]
    ]
}

// MARK: UI
extension ChattingView {
    /// Nav
    private var navigationBar: some View {
        ZStack(alignment: .center) {
            Text("바쁜굴비님의 토론방")
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
            
            HStack {
                ImageHelper.back.asImage
                    .resizable()
                    .frame(width: 32, height: 32)
                    .asButton {

                    }
                Spacer()
            }
        }
    }
    
    /// Product Section
    private var productSection: some View {
        HStack(spacing: 0) {
            DownImageView(url: URL(string: "https://image.msscdn.net/thumbnails/images/goods_img/20250903/5397926/5397926_17582584972271_big.jpg?w=1200"), option: .min)
                .frame(width: 36, height: 36)
            
            6.widthBox
            
            VStack(alignment: .leading, spacing: 0) {
                Text("테켓 후드티")
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.white.asColor)
                Text("89,000원")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.white.asColor)
            }
            
            Spacer()
            
            6.widthBox
            
            Text("수정")
                .font(FontHelper.btn4.font)
                .foregroundStyle(GBColor.black.asColor)
                .padding(.horizontal, .md)
                .padding(.vertical, .sm)
                .background(GBColor.white.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .asButton {
                    
                }
            4.widthBox
        }
        .padding(.horizontal, .lg)
        .padding(.vertical, .sm)
        .border(GBColor.grey600.asColor, width: 1)
    }
    
    var textInputSection: some View {
        HStack(spacing: 8) {
            DisablePasteTextField(
                text: $sendText,
                placeholder: "메세지를 입력하세요",
                placeholderColor: GBColor.grey300.asColor,
                edge: UIEdgeInsets(
                    top: 11,
                    left: 16,
                    bottom: 11,
                    right: 10
                ),
                keyboardType: .default,
                items: [.keyboardDown]
            ) {
                    
            }
            .background(GBColor.grey600.asColor)
            .clipShape(RoundedRectangle(cornerRadius: 99))
            .overlay(
                RoundedRectangle(cornerRadius: 99)
                    .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
            )
            .fixedSize(horizontal: false, vertical: true)
            
            ImageHelper.paperPlane.asImage
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.all, .xs)
                .background(GBColor.main.asColor)
                .clipShape(Circle())
        }
        .padding(.horizontal, .md)
        .padding(.vertical, .sm)
        .border(GBColor.grey500.asColor, width: 1)
    }
}

#if DEBUG
#Preview {
    ChattingView()
}
#endif
