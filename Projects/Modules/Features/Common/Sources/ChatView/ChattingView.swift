//
//  ChattingView.swift
//  FeatureCommon
//
//  Created by Jae hyung Kim on 3/31/26.
//

import SwiftUI
import ComposableArchitecture
import Utils

public struct ChattingView: View {
    @Perception.Bindable var store: StoreOf<ChattingViewFeature>

    public init(store: StoreOf<ChattingViewFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                navigationBar
                    .padding(.horizontal, .md)
                    .padding(.vertical, .md)

                if store.isReconnecting {
                    reconnectingBanner
                }
                 
                productSection(isLoading: false)
                
                listSection
                    .resetListStyle()
                
                textInputSection
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoreAreaBackgroundColor(GBColor.background1.asColor)
            .onAppear {
                store.send(.viewCycle(.onAppear))
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                store.send(.viewCycle(.willEnterForeground))
            }
            .onDisappear {
                store.send(.viewCycle(.onDisappear))
            }
            .popup(item: $store.showErrorMessage.sending(\.showErrorMessage)) { message in
                GBAlertView(model: .init(title: "ERROR", message: message, okTitle: "확인", alertStyle: .warning)) {}
                okTouch: {
                    store.send(.showErrorMessage(message: nil))
                }
            }
        }
    }
    
    private var listSection: some View {
        ScrollViewReader { proxy in
            WithPerceptionTracking {
                List {
                    let renderingItems = store.isInitialLoading
                        ? ChattingViewFeature.buildListItems(from: ChattingViewFeature.loadingPlaceholderMessages)
                        : store.listItems

                    20.heightBox
                        .resetRowStyle()
                        .listRowBackground(Color.clear)

                    ForEach(Array(renderingItems.enumerated()), id: \.element.id) { index, item in
                        switch item {
                        case let .date(dateString):
                            dateSection(dateString: dateString)
                                .padding(.bottom, .lg)
                                .skeletonEffect(isActive: store.isInitialLoading)
                                .resetRowStyle()
                                .listRowBackground(Color.clear)
                                .onAppear {
                                    if !store.isInitialLoading {
                                        store.send(.viewEvent(.loadMoreIfNeeded(index)))
                                    }
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
                            .skeletonEffect(isActive: store.isInitialLoading)
                            .resetRowStyle()
                            .listRowBackground(Color.clear)
                            .onAppear {
                                if !store.isInitialLoading {
                                    store.send(.viewEvent(.loadMoreIfNeeded(index)))
                                }
                            }
                        }
                    }

                    Color.clear
                        .frame(height: 1)
                        .id("chatListBottom")
                        .resetRowStyle()
                        .listRowBackground(Color.clear)
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                )
                .onChange(of: store.listItems.count) { _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("chatListBottom", anchor: .bottom)
                    }
                }
                .onChange(of: store.isInitialLoading) { isLoading in
                    guard !isLoading else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo("chatListBottom", anchor: .bottom)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo("chatListBottom", anchor: .bottom)
                        }
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
}

// MARK: UI
extension ChattingView {
    private var reconnectingBanner: some View {
        Text("채팅 연결을 다시 시도하고 있어요…")
            .font(FontHelper.body5.font)
            .foregroundStyle(GBColor.white.asColor)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, .sm)
            .background(GBColor.main.asColor.opacity(0.8))
    }

    /// Nav
    private var navigationBar: some View {
        ZStack(alignment: .center) {
            Text(store.userName) // TODO API 변경 해줘야 반영함
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
            
            HStack {
                ImageHelper.back.asImage
                    .resizable()
                    .frame(width: 32, height: 32)
                    .asButton {
                        store.send(.viewEvent(.backTapped))
                    }
                Spacer()
            }
        }
    }
    
    /// Product Section
    private func productSection(isLoading: Bool) -> some View {
        
        let dummyTitle = "Dummy Product Name"
        let dummyPrice = "10,000원"
        
        return HStack(spacing: 0) {
            if (isLoading) {
                Rectangle()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .skeletonEffect(isActive: isLoading)
            } else {
                DownImageView(url: store.product?.imageURLString, option: .mid)
                    .frame(width: 36, height: 36)
            }
                
            
            6.widthBox
            
            VStack(alignment: .leading, spacing: 0) {
                Text((isLoading ? dummyTitle : store.product?.name) ?? "")
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.white.asColor)
                Text((isLoading ? dummyPrice : store.product?.priceText) ?? "")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.white.asColor)
            }
            .skeletonEffect(isActive: isLoading)
            
            Spacer()
            
            6.widthBox
            
            Text(store.product?.editButtonTitle ?? "")
                .font(FontHelper.btn4.font)
                .foregroundStyle(GBColor.black.asColor)
                .padding(.horizontal, .md)
                .padding(.vertical, .sm)
                .background(GBColor.white.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .asButton {
                    store.send(.viewEvent(.productEditTapped))
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
                text: Binding(
                    get: { store.sendText },
                    set: { store.send(.viewEvent(.bindingSendText($0))) }
                ),
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
                store.send(.viewEvent(.sendTapped))
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
                .asButton {
                    store.send(.viewEvent(.sendTapped))
                }
        }
        .padding(.horizontal, .md)
        .padding(.vertical, .sm)
        .border(GBColor.grey500.asColor, width: 1)
        .opacity(store.isSocketConnected && !store.isReconnecting ? 1 : 0.6)
    }
}

#if DEBUG
//#Preview {
//    ChattingView(
//        store: Store(
//            initialState: ChattingViewFeature.State(userName: <#String#>, userID: <#String#>, model: <#BuyOrNotCardViewEntity#>)) {
//            ChattingViewFeature()
//        }
//    )
//}
#endif
