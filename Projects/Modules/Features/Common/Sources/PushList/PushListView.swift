//
//  PushListView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/1/25.
//

import SwiftUI
import ComposableArchitecture
import Utils
import Data

public struct PushListView: View {
    
    public init(store: StoreOf<PushListViewFeature>) {
        self.store = store
    }
    
    @Perception.Bindable var store: StoreOf<PushListViewFeature>
        
    public var body: some View {
        WithPerceptionTracking {
            contentView
                .onFirstAppear {
                    store.send(.viewCycle(.onAppear))
                }
        }
    }
}

extension PushListView {
    private var contentView: some View {
        VStack(spacing: 0) {
            navigationBarView
                .padding(.all, SpacingHelper.md.pixel)
                
            switch store.dataEmptyCase {
            case .loading:
                
                emptyListSkeletonView
                
            case .loaded:
                
                filterView
                    .padding(.vertical, SpacingHelper.sm.pixel)
                listView
                
            case .empty:
                filterView
                    .padding(.vertical, SpacingHelper.sm.pixel)
                emptyListView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GBColor.background1.asColor)
    }
}

extension PushListView {
    private var navigationBarView: some View {
        ZStack {
            HStack(spacing: 0) {
                Image(uiImage: ImageHelper.back.image)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .asButton {
                        store.send(.viewEvent(.dismissTap))
                    }
                Spacer()
            }
            
            Text("알림 목록")
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.grey100.asColor)
        }
    }
}

extension PushListView {
    private var filterView: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: SpacingHelper.sm.pixel) {
                    ForEach(PushListFilterCase.allCases, id: \.self) { caseOf in
                        filterCaseView(caseOf)
                            .asButton {
                                // Store
                                store.send(.viewEvent(.selectedFilterCase(caseOf)))
                            }
                    }
                }
                .padding(.horizontal, SpacingHelper.md.pixel)
            }
        }
    }
    
    private func filterCaseView(_ caseOf: PushListFilterCase) -> some View {
        VStack(spacing: 0) {
            Text(caseOf.title)
                .font(FontHelper.btn4.font)
                .padding(.vertical, SpacingHelper.sm.pixel)
                .padding(.horizontal, SpacingHelper.md.pixel)
                .foregroundStyle(
                    filterTitleColor(from: caseOf)
                )
        }
        .background(
            filterBackGroundColor(from: caseOf)
        )
        .clipShape(Capsule())
    }
    
    /// 필터 버튼 색상을 지정합니다.
    /// - Parameter from: 해당 케이스
    /// - Returns: 현재 케이스와 비교한후 색상
    private func filterTitleColor(from: PushListFilterCase) -> Color {
        let bool = store.currentFilterCase == from
        return bool ? GBColor.black.asColor : GBColor.grey200.asColor
    }

    /// 필터 버튼 백그라운드 색상을 지정합니다.
    /// - Parameter from: 해당 케이스
    /// - Returns: 현재 케이스와 비교한후 색상
    private func filterBackGroundColor(from: PushListFilterCase) -> Color {
        let bool = store.currentFilterCase == from
        return bool ? GBColor.white.asColor : GBColor.grey600.asColor
    }
}

extension PushListView {
    
    private var listView: some View {
        ScrollViewReader { proxy in
            List(Array(store.items.enumerated()), id: \.element.id) { index, item in
                challengeItemView(from: item)
                    .asButton {
                        store.send(.viewEvent(.selectedItem(item)))
                    }
                    .resetRowStyle()
                    .listRowBackground(Color.clear)
                    .onAppear {
                        if let lastId = store.items.last?.id,
                           lastId == item.id {
                            store.send(.viewEvent(.postListIndex(index)))
                        }
                    }
                    .id(index)
            }
            .listStyle(.plain)
            .onChange(of: store.currentFilterCase) { _ in
                withAnimation {
                    proxy.scrollTo(0)
                }
            }
        }
        
    }
    
    private var emptyListSkeletonView: some View {
        VStack(spacing: 0) {

            filterView
                .skeletonEffect()
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0...2, id: \.self) { idx in
                        challengeItemView(from: PushListItemEntity(
                            id: idx.toString,
                            receiverId: "ASDASD!",
                            challengeTopCase: .challenge,
                            description: "오늘 아직 [커피 값 모아 태산]을 달성하지 못했어요.\n늦기전에 인증해주세요",
                            pushDateTiem: "3분전",
                            read: true)
                        )
                        .skeletonEffect()
                    }
                }
            }
        }
    }
    
    private func challengeItemView(from: PushListItemEntity) -> some View {
        VStack (spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                setChallengeImage(from: from)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.trailing, SpacingHelper.sm.pixel)
                
                VStack(alignment: .leading, spacing: SpacingHelper.xs.pixel) {
                    HStack(spacing: 0) {
                        Text(from.challengeTopCase.title)
                            .font(FontHelper.body5.font)
                            .foregroundStyle(GBColor.grey300.asColor)
                        
                        Spacer()
                        
                        Text(from.pushDateTiem)
                            .font(FontHelper.body5.font)
                            .foregroundStyle(GBColor.grey300.asColor)
                    }
                    
                    ArrangeTextView(
                        text: from.description,
                        defaultFont: FontHelper.body4.font,
                        type: .big,
                        targetFont: FontHelper.body3.font
                    )
                }
            }
            .padding(.all, SpacingHelper.lg.pixel)
            
            Divider()
        }
    }
    
    private func setChallengeImage(from: PushListItemEntity) -> Image {
        switch from.challengeTopCase {
        case .all:
            return ImageHelper.pushNull.asImage
        case .challenge:
            return ImageHelper.pushChallenge.asImage
        case .chatting:
            return ImageHelper.pushChatting.asImage
        case .voteResult:
            return ImageHelper.pushVote.asImage
        }
    }
    
    private func checkToIndex(index: Int) {
        if !store.loadingTrigger,
           !store.items.isEmpty,
           (store.items.count - 3) < index
        {
            store.send(.viewEvent(.postListIndex(index)))
        }
    }
}


extension PushListView {
    
    private var bottomView: some View {
        HStack(spacing: 0) {
            ImageHelper.warning.asImage
                .resizable()
                .frame(width: 32, height: 32)
            
            Text("알림은 최대 30일까지 보관됩니다")
                .font(FontHelper.body5.font)
                .foregroundStyle(GBColor.grey300.asColor)
        }
        .padding(.vertical, SpacingHelper.lg.pixel)
        .padding(.horizontal, SpacingHelper.md.pixel)
    }
}

extension PushListView {
    
    private var emptyListView: some View {
        VStack (spacing: 0) {
            
            
            ImageHelper.appLogo.asImage
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, UIScreen.main.bounds.width / 4)
                .grayscale(1)
                .padding(.top, UIScreen.main.bounds.height * 0.1)
            
            Text("새로운 알림이 없어요")
                .foregroundStyle(GBColor.grey300.asColor)
                .font(FontHelper.body2.font)
                
            
            Spacer()
        }
    }
    
}
