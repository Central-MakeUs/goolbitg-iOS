//
//  RevokeReasonView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/6/25.
//

import SwiftUI
import ComposableArchitecture
import Combine

struct RevokeReasonView: View {
    
    @Perception.Bindable var store: StoreOf<RevokeFeature>
    
    @State var keyboardHeight: CGFloat = 0
    @Namespace private var scrollToBottom
   
    var body: some View {
        WithPerceptionTracking {
            WithPerceptionTracking {
                contentView
                    .onTapGesture {
                        endTextEditing()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
                               perform: { notification in
                        guard let userInfo = notification.userInfo,
                              let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                        
                        keyboardHeight = keyboardRect.height
                        
                    }).onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
                                 perform: { _ in
                        keyboardHeight = 0
                    })
            }
        }
    }
}

extension RevokeReasonView {
    private var contentView: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                navigationBar
                    .padding(.horizontal, SpacingHelper.md.pixel)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        headerView
                            .padding(.horizontal, SpacingHelper.md.pixel + SpacingHelper.sm.pixel)
                        
                        revokeReasonList(proxy: proxy)
                            .padding(.top, SpacingHelper.md.pixel)
                            .padding(.horizontal, SpacingHelper.md.pixel + SpacingHelper.sm.pixel)
                        
                        
                        ZStack {
                            Color.clear
                                .frame(height: 100)
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding(.bottom, keyboardHeight / 1.5)
                    .onChange(of: keyboardHeight) { newValue in
                        if newValue != 0 {
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 1)) {
                                    proxy.scrollTo(scrollToBottom, anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
            
            nextButton
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .background(GBColor.background1.asColor)
        .ignoresSafeArea(.keyboard)
    }
    
    private var navigationBar: some View {
        ZStack(alignment: .center) {
            Text(TextHelper.myPage)
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
            
            HStack {
                ImageHelper.back.asImage
                    .resizable()
                    .frame(width: 32, height: 32)
                    .asButton {
                        store.send(.viewAction(.dismiss))
                    }
                Spacer()
            }
        }
    }
    
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(TextHelper.revokeTopTitle)
                    .multilineTextAlignment(.leading)
                    .font(FontHelper.h1.font)
                    .foregroundStyle(GBColor.white.asColor)
                
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, SpacingHelper.lg.pixel)
            
            HStack(spacing: 0) {
                Text(TextHelper.revokeTopSubTitle)
                    .font(FontHelper.body1.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                Spacer()
            }
        }
    }
    
    private func revokeReasonList(proxy: ScrollViewProxy) -> some View {
        VStack(spacing:SpacingHelper.md.pixel) {
            ForEach(RevokeCase.allCases, id: \.self) { item in
                CommonCheckListButtonView(configuration: CommonCheckListConfiguration(
                    currentState: item == store.item,
                    checkListTitle: item.title,
                    subText: nil)
                )
                .asButton {
                    store.send(.viewAction(.selected(item)))
                }
                
                if item == .other, store.item == .other {
                    otherTextView
                        
                }
            }
            
            Color.clear
                .frame(height: 1)
                .id(scrollToBottom)
        }
    }
    
    private var otherTextView: some View {
        VStack(spacing: 0) {
            DisablePasteTextField(
                text: $store.content.sending(\.contentBinding),
                placeholder: "사유를 작성해 주세요 (선택사항)",
                placeholderColor: GBColor.grey400.asColor,
                edge: UIEdgeInsets(
                    top: SpacingHelper.md.pixel,
                    left: SpacingHelper.md.pixel,
                    bottom: SpacingHelper.md.pixel,
                    right: SpacingHelper.md.pixel
                ),
                keyboardType: .asciiCapable
            ) {
                
            }
        }
        .frame(height: 48)
        .background(GBColor.grey600.asColor)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(lineWidth: 1)
                .foregroundStyle(GBColor.grey500.asColor)
        }
    }
    
    private var nextButton: some View {
        VStack(spacing: 0) {
            if store.item != nil, keyboardHeight < 20 {
                GBButtonV2(
                    title: "탈퇴하기") {
                        store.send(.viewAction(.revokeButtonTapped))
                    }
            }
        }
    }
}


#Preview {
    RevokeReasonView(store: Store(initialState: RevokeFeature.State(), reducer: {
        RevokeFeature()
    }))
}
