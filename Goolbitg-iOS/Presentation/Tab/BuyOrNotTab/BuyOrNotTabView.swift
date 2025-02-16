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
    
    @State private var animationDirection: CGFloat = 0
    
    @State private var emptyList: [BuyOrNotCardViewEntity] = BuyOrNotCardViewEntity.dummy()
    
    @State private var emptyListIndex = 0
    
    var body: some View {
        WithPerceptionTracking {
            content
                .onAppear {
                    store.send(.viewCycle(.onAppear))
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
                            .backgroundView {
                                Color.black.opacity(0.5)
                            }
                    }
        }
    }
}

extension BuyOrNotTabView {
    private var content: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.top, SpacingHelper.xs.pixel)
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.bottom, SpacingHelper.sm.pixel)
            
            buyOrNotView
                
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
                    withAnimation {
                        store.send(.bindingTabMode(.buyOrNot))
                        animationDirection = -1
                    }
                }
                .padding(.trailing, 4)
            
            Text("기록")
                .font(headerTitleFont(mode: .records , by: currentTab))
                .foregroundStyle(headerTitleColor(mode: .records, by: currentTab))
                .asButton {
                    withAnimation {
                        store.send(.bindingTabMode(.records))
                        animationDirection = 1
                    }
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
