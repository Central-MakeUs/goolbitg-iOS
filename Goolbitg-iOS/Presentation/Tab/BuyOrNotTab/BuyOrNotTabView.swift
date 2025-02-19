//
//  BuyOrNotTabView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

enum BuyOrNotTabInMode {
    case buyOrNot
    case records
    
    var title: String {
        switch self {
        case .buyOrNot:
            return "살까말까"
        case .records:
            return "기록"
        }
    }
}

struct BuyOrNotTabView: View {
    
    @Perception.Bindable var store: StoreOf<BuyOrNotTabViewFeature>
    
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    @State private var emptyList: [BuyOrNotCardViewEntity] = BuyOrNotCardViewEntity.dummy()
    
    @State private var emptyListIndex = 0
    
    @State private var tabMode: BuyOrNotTabInMode = .buyOrNot
    
    @State private var ifModifierOrDelete: BuyOrNotCardViewEntity? = nil
    @State private var popupPosition: CGPoint = .zero
    
    private let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        WithPerceptionTracking {
            content
                .onChange(of: store.tabMode) {  newValue in
                    withAnimation {
                        tabMode = newValue
                    }
                }
                .popup(
                    item: $store.errorAlert.sending(\.bindingAlert)) { item in
                        GBAlertView(
                            model: item) {}
                        okTouch: {
                            store.send(.bindingAlert(nil))
                        }
                    } customize: {
                        $0
                            .animation(.easeInOut)
                            .type(.default)
                            .appearFrom(.centerScale)
                            .closeOnTap(false)
                            .closeOnTapOutside(false)
                            .backgroundColor(Color.black.opacity(0.5))
                    }
                    .popup(item: $ifModifierOrDelete) { item in
                        GBBottonSheetView {
                            AnyView(modifierBottomSheetTop)
                        } contentView: {
                            AnyView(modifierBottomSheetBottom)
                        }
                        .frame(maxWidth: .infinity)
                        .background(GBColor.grey600.asColor)
                        .cornerRadiusCorners(12, corners: [.topLeft, .topRight])
                        
                    } customize: {
                        $0
                            .type(.toast)
//                            .displayMode(.sheet)
                            .closeOnTap(false)
                            .closeOnTapOutside(true)
                            .animation(.smooth)
                            .backgroundColor(Color.black.opacity(0.5))
//                            .backgroundView {
//                                Color.black.opacity(0.5)
//                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            }
                    }
        }
    }
    
    private var modifierBottomSheetTop: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("수정하기")
                    .font(FontHelper.body1.font)
                    .foregroundStyle(GBColor.white.asColor)
                    .padding(.vertical, SpacingHelper.sm.pixel)
                Spacer()
            }
            .asButton {
                
            }
            .padding(.horizontal, SpacingHelper.lg.pixel)
            
            Divider()
                .padding(.vertical, SpacingHelper.sm.pixel)
                .padding(.horizontal, SpacingHelper.md.pixel)
            HStack {
                Spacer()
                Text("삭제하기")
                    .font(FontHelper.body1.font)
                    .foregroundStyle(GBColor.error.asColor)
                    .padding(.vertical, SpacingHelper.sm.pixel)
                Spacer()
            }
            .asButton {
                
            }
            .padding(.horizontal, SpacingHelper.lg.pixel)
        }
        .padding(.vertical, SpacingHelper.md.pixel)
    }
    
    private var modifierBottomSheetBottom: some View {
        VStack(spacing: 0) {
            Text("닫기")
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
                .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .background(GBColor.grey500.asColor)
        .clipShape(Capsule())
        .padding(.all, 16)
        .asButton {
            ifModifierOrDelete = nil
        }
        .padding(.bottom, safeAreaInsets.bottom)
    }
}

extension BuyOrNotTabView {
    private var content: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.top, SpacingHelper.xs.pixel)
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.bottom, SpacingHelper.sm.pixel)
            
            VStack(spacing: 0) {
                if tabMode == .buyOrNot {
                    buyOrNotView
                        .onAppear {
                            store.send(.viewCycle(.onAppear))
                        }
                }
                else if tabMode == .records {
                    buyOrNotRecordView
                        .onAppear {
                            store.send(.viewCycle(.recordOnAppear))
                        }
                }
            }
            Spacer()
            
            Color.clear
                .frame(height: safeAreaInsets.bottom)
            
        }
        .background(GBColor.background1.asColor)
    }
    
    private var headerView: some View {
        let currentTab = store.tabMode
        
        return HStack(spacing: 0) {
            Text("살까말까")
                .font(headerTitleFont(mode: .buyOrNot , by: currentTab))
                .foregroundStyle(headerTitleColor(mode: .buyOrNot, by: currentTab))
                .asButton {
                    store.send(.bindingTabMode(.buyOrNot))
                }
                .padding(.trailing, 4)
            
            Text("기록")
                .font(headerTitleFont(mode: .records , by: currentTab))
                .foregroundStyle(headerTitleColor(mode: .records, by: currentTab))
                .asButton {
                    store.send(.bindingTabMode(.records))
                }
            Spacer()
            
            ImageHelper.buyOrNotAdd.asImage
                .resizable()
                .frame(width: 40, height: 40)
                .asButton {
                    store.send(.viewEvent(.addButtonTapped))
                }
            
        }
    }
    
    
    private var buyOrNotView: some View {
        let screenHeight = UIScreen.main.bounds.height
        let safeHeight = safeAreaInsets.bottom + safeAreaInsets.top
        
        let ifCardViewHeight = (screenHeight - safeHeight) * 0.68
        
        return VStack(spacing: 0) {
            GeometryReader { proxy in
                WithPerceptionTracking {
                    if store.currentList.isEmpty {
                        BuyOrNotCardView(entity: emptyList.first!, reportTab: {
                            
                        })
                        .padding(.horizontal, SpacingHelper.lg.pixel)
                        .padding(.top, SpacingHelper.lg.pixel)
                        .skeletonEffect()
                        
                    } else {
                        BuyOrNotCardListView(
                            currentListEntity: $store.currentList.sending(\.bindingCurrentList),
                            currentIndex: $store.currentIndex.sending(\.bindingCurrentIndex),
                            size: proxy.size) { selected in
                                print(selected)
                            } reportEntity: { report in
                                print(report)
                            }
                            .onAppear {
                                emptyListIndex = 0
                            }
                    }
                }
            }
            .frame(height: ifCardViewHeight)
            .padding(.bottom, 24)
            
            likeOrNotView
        }
    }
    
    private var likeOrNotView: some View {
        let index = store.currentIndex
        let model = store.currentList[safe: index]
        
        return HStack(spacing: 40) {
            VStack(spacing: SpacingHelper.sm.pixel) {
                Circle()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(GBColor.white.asColor.opacity(0.1))
                    .overlay {
                        ImageHelper.good.asImage
                            .resizable()
                            .frame(width: 39, height: 35.7)
                            .offset(x: 3, y: -2)
                    }
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 1)
                            .foregroundStyle(GBColor.white.asColor.opacity(0.1))
                    }
                
                currentItemGoodOrNotCount(ifGood: true)
            }
            .asButton {
                store.send(.viewEvent(.likeButtonTapped(model, index: index)))
            }
            
            VStack(spacing: SpacingHelper.sm.pixel) {
                Circle()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(GBColor.white.asColor.opacity(0.1))
                    .overlay {
                        ImageHelper.bad.asImage
                            .resizable()
                            .frame(width: 39, height: 35.7)
                            .offset(x: -3, y: 2)
                    }
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 1)
                            .foregroundStyle(GBColor.white.asColor.opacity(0.1))
                    }
                
                currentItemGoodOrNotCount(ifGood: false)
            }
            .asButton {
                store.send(.viewEvent(.disLikeButtonTapped(model, index: index)))
            }
        }
    }
    
    
    private func currentItemGoodOrNotCount(ifGood: Bool) -> some View {
        let model = store.currentList[safe: store.currentIndex]
        
        return Group {
            if let model {
                if ifGood {
                    Text(model.goodVoteCount)
                }
                else {
                    Text(model.badVoteCount)
                }
            }
            else {
                Text("??")
            }
        }
        .foregroundStyle(GBColor.grey400.asColor)
        .font(FontHelper.caption2.font)
    }
}

extension BuyOrNotTabView {
    private var buyOrNotRecordView: some View {
        VStack(spacing: 0) {
            
            recordHeaderView
                .padding(.horizontal, SpacingHelper.lg.pixel)
                .padding(.vertical, SpacingHelper.sm.pixel)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(store.currentUserList.enumerated()), id: \.element.id) { idx, item in
                        MyWriteListView(model: item)
                    }
                }
            }
        }
    }
    
    private var recordHeaderView: some View {
        HStack(spacing: 0) {
            Text("내가 작성한 글")
                .font(FontHelper.body3.font)
                .foregroundStyle(GBColor.white.asColor)
            Spacer()
        }
    }
    
    private func MyWriteListView(model: BuyOrNotCardViewEntity) -> some View {
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                DownImageView(url: model.imageUrl, option: .min)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(GBColor.grey500.asColor)
                    }
                    .padding(.trailing, SpacingHelper.md.pixel)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(model.itemName)
                            .font(FontHelper.body3.font)
                            .foregroundStyle(GBColor.white.asColor)
                            .padding(.bottom, SpacingHelper.xs.pixel)
                        Spacer()
                    }
                    HStack {
                        Text(model.priceString)
                            .font(FontHelper.body4.font)
                            .foregroundStyle(GBColor.white.asColor)
                        Spacer()
                    }
                    Spacer()
                    
                    HStack(spacing: 0) {
                        
                        ImageHelper.miniLikeHand
                            .asImage
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(
                                setLikeAndBadColor(goodOrBadOrNot: model.goodMoreOrBadMore, by: .good)
                            )
                            .padding(.trailing, 4)
                        
                        Text(model.goodVoteCount)
                            .font(FontHelper.body5.font)
                            .foregroundColor(
                                setLikeAndBadColor(goodOrBadOrNot: model.goodMoreOrBadMore, by: .good)
                            )
                            .padding(.trailing, SpacingHelper.sm.pixel)
                        
                        ImageHelper.miniUnlikeHand
                            .asImage
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(
                                setLikeAndBadColor(goodOrBadOrNot: model.goodMoreOrBadMore, by: .bad)
                            )
                            .padding(.trailing, 4)
                        
                        Text(model.badVoteCount)
                            .font(FontHelper.body5.font)
                            .foregroundColor(
                                setLikeAndBadColor(goodOrBadOrNot: model.goodMoreOrBadMore, by: .bad)
                            )
                    }
                }
                .padding(.vertical, SpacingHelper.xs.pixel)
                VStack {
                    
                    GeometryReader { proxy in
                        Image(systemName: "ellipsis")
                            .resizable()
                            .frame(width: 18, height: 3)
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(GBColor.white.asColor)
                            .padding(.trailing, SpacingHelper.sm.pixel)
                            .frame(width: 32)
                            .asButton {
                                withAnimation {
                                    ifModifierOrDelete = model
                                }
                            }
                          
                    }
                    .frame(width: 20, height: 3)
                    Spacer()
                    
                }
                
                .padding(.vertical, SpacingHelper.xs.pixel)
            }
            .padding(.vertical, SpacingHelper.md.pixel)
        }
        .padding(.horizontal, SpacingHelper.md.pixel)
        .frame(height: 112)
        
    }
    
    private func setLikeAndBadColor(goodOrBadOrNot: GoodOrBadOrNot, by: GoodOrBadOrNot) -> Color {
        goodOrBadOrNot == by ? GBColor.main.asColor : GBColor.grey300.asColor
    }
}


extension BuyOrNotTabView {
    private func headerTitleColor(mode: BuyOrNotTabInMode, by: BuyOrNotTabInMode) -> Color {
        return mode == by ? GBColor.white.asColor : GBColor.grey400.asColor
    }
    
    private func headerTitleFont(mode: BuyOrNotTabInMode, by: BuyOrNotTabInMode) -> Font {
        return mode == by ? FontHelper.h1.font : FontHelper.h2.font
    }
}


#if DEBUG
#Preview {
    BuyOrNotTabView(store: Store(initialState: BuyOrNotTabViewFeature.State(), reducer: {
        BuyOrNotTabViewFeature()
    }))
}
#endif
