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
    @State private var ifReportModelID: String? = nil
    @State private var currentSelectedIdx: Int? = nil
    @State private var popupPosition: CGPoint = .zero
    @State private var currentUserListIdx = 0
    
    private let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        WithPerceptionTracking {
            content
                .onChange(of: store.tabMode) {  newValue in
                    withAnimation {
                        tabMode = newValue
                    }
                }
                .onChange(of: store.loading) { newValue in
                    LoadingEnvironment.shared.loading(newValue)
                }
                .popup(
                    item: $store.errorAlert.sending(\.bindingAlert)) { item in
                        VStack(spacing: 0) {
                            Spacer()
                            GBAlertView(
                                model: item) {
                                    store.send(.bindingAlert(nil))
                                }
                            okTouch: {
                                store.send(.viewEvent(.alertOkTapped(item: item)))
                            }
                            Spacer()
                        }
                    } customize: {
                        $0
                            .type(.floater())
                            .animation(.easeInOut)
                            .appearFrom(.centerScale)
                            .displayMode(.sheet)
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
                            .closeOnTap(false)
                            .closeOnTapOutside(true)
                            .animation(.smooth)
                            .backgroundColor(Color.black.opacity(0.5))
                    }
                    .popup(item: $ifReportModelID) { item in
                        BuyOrNotModifyBottomSheetView { reason in
                            ifReportModelID = nil
                            store.send(.viewEvent(.reportButtonTapped(id: item, reason: reason)))
                        }
                    } customize: {
                        $0
                            .type(.toast)
                            .closeOnTap(false)
                            .closeOnTapOutside(true)
                            .animation(.smooth)
                            .backgroundColor(Color.black.opacity(0.5))
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
                guard let entity = self.ifModifierOrDelete,
                      let selectedIDX = currentSelectedIdx else {
                    self.ifModifierOrDelete = nil
                    self.currentSelectedIdx = nil
                    return
                }
                
                self.ifModifierOrDelete = nil
                self.currentSelectedIdx = nil
                Task {
                    try? await Task.sleep(for: .seconds(0.7))
                    store.send(.viewEvent(.modifierModel(entity, index: selectedIDX)))
                }
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
                guard let entity = self.ifModifierOrDelete,
                      let selectedIDX = currentSelectedIdx else {
                    self.ifModifierOrDelete = nil
                    self.currentSelectedIdx = nil
                    return
                }
                self.ifModifierOrDelete = nil
                self.currentSelectedIdx = nil
                Task {
                    try? await Task.sleep(for: .seconds(0.7))
                    store.send(.viewEvent(.deleteModel(entity, index: selectedIDX)))
                }
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
            self.ifModifierOrDelete = nil
            self.currentSelectedIdx = nil
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
                        .onChange(of: currentUserListIdx) { idx in
                            checkCurrentUserIdx(idx: idx)
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
                                ifReportModelID = report.id
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
                        MyWriteListView(model: item, idx: idx)
                            .onAppear {
                                currentUserListIdx = idx
                            }
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
    
    private func MyWriteListView(model: BuyOrNotCardViewEntity, idx: Int) -> some View {
        
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
                                currentSelectedIdx = idx
                            }
                        }
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
    
    private func checkCurrentUserIdx(idx: Int) {
        Task {
            let currentList = store.currentList
            if !store.userListPagingTrigger,
               !currentList.isEmpty,
               (currentList.count - 3) > 0,
               (currentList.count - 3) < idx {
                store.send(.viewEvent(.moreUserList(index: idx)))
            }
        }
    }
}

enum ReportCase: Equatable, CaseIterable {
    case adult
    case fight
    case wrong
    case other
    
    var reason: String {
        switch self {
        case .adult:
            return "성적인 콘텐츠"
        case .fight:
            return "폭력적 또는 혐오스러운 콘텐츠"
        case .wrong:
            return "잘못된 정보"
        case .other:
            return "기타 사유"
        }
    }
}

struct BuyOrNotModifyBottomSheetView: View {
    
    @State private var ifCurrentReportCase: ReportCase? = nil
    @State private var currentButtonState = false
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    let reportButtonTapped: (ReportCase) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .foregroundStyle(GBColor.grey300.asColor)
                .frame(width: 32, height: 4)
                .padding(.top, SpacingHelper.md.pixel)
                .padding(.horizontal, SpacingHelper.md.pixel)
                
            reportHeaderView
            Divider()
                .foregroundStyle(GBColor.grey300.asColor)
                .padding(.bottom, SpacingHelper.sm.pixel)
            
            reportFooterView
        }
        .frame(maxWidth: .infinity)
        .background(GBColor.grey600.asColor)
        .cornerRadiusCorners(12, corners: [.topLeft, .topRight])
    }
    
    private var reportFooterView: some View {
        VStack (spacing: 0) {
            LazyVStack (spacing: SpacingHelper.md.pixel) {
                ForEach(ReportCase.allCases, id: \.self) { item in
                    CommonCheckListButtonView(
                        configuration: CommonCheckListConfiguration(
                            currentState: ifCurrentReportCase == item,
                            checkListTitle: item.reason,
                            subText: nil)
                    )
                    .asButton {
                        if ifCurrentReportCase == nil {
                            ifCurrentReportCase = item
                            currentButtonState = true
                        }
                        else if ifCurrentReportCase != item{
                            ifCurrentReportCase = item
                            currentButtonState = true
                        }
                        else {
                            ifCurrentReportCase = nil
                            currentButtonState = false
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Divider()
                .foregroundStyle(GBColor.grey300.asColor)
                .padding(.top, SpacingHelper.sm.pixel)
            
            GBButton(
                isActionButtonState: $currentButtonState,
                title: "신고하기") {
                    if let ifCurrentReportCase {
                        reportButtonTapped(ifCurrentReportCase)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.all, 16)
                .padding(.bottom, safeAreaInsets.bottom)
        }
    }
    
    
    private var reportHeaderView: some View {
        VStack(spacing: 4) {
            HStack {
                Spacer()
                Text("신고하기")
                    .font(FontHelper.h3.font)
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }
            HStack {
                Spacer()
                Text("신고하려는 이유를 선택해 주세요")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.grey200.asColor)
                Spacer()
            }
        }
        .padding(.all, SpacingHelper.sm.pixel)
    }
}

#if DEBUG
#Preview {
    BuyOrNotTabView(store: Store(initialState: BuyOrNotTabViewFeature.State(), reducer: {
        BuyOrNotTabViewFeature()
    }))
//    BuyOrNotModifyBottomSheetView()
}
#endif
