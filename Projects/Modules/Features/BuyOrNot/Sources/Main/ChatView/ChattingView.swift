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
    let store: StoreOf<ChattingViewFeature>
    
    init(store: StoreOf<ChattingViewFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                navigationBar
                    .padding(.horizontal, .md)
                    .padding(.vertical, .md)
                
                productSection(isLoading: false)
                    .padding(.bottom, 20)
                
                listSection
                    .resetListStyle()
                
                textInputSection
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoreAreaBackgroundColor(GBColor.background1.asColor)
            .onAppear {
                store.send(.viewCycle(.onAppear))
            }
        }
    }
    
    private var listSection: some View {
        List {
            if store.isPaging {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .sm)
                    .resetRowStyle()
                    .listRowBackground(Color.clear)
            }
            
            let renderingItems = store.isInitialLoading
                ? ChattingViewFeature.buildListItems(from: ChattingViewFeature.loadingPlaceholderMessages)
                : store.listItems
            
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
    /// Nav
    private var navigationBar: some View {
        ZStack(alignment: .center) {
            Text(store.roomTitle)
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
                DownImageView(url: URL(string: store.product.imageURLString), option: .min)
                    .frame(width: 36, height: 36)
            }
                
            
            6.widthBox
            
            VStack(alignment: .leading, spacing: 0) {
                Text(isLoading ? dummyTitle : store.product.name)
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.white.asColor)
                Text(isLoading ? dummyPrice : store.product.priceText)
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.white.asColor)
            }
            .skeletonEffect(isActive: isLoading)
            
            Spacer()
            
            6.widthBox
            
            Text(store.product.editButtonTitle)
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
    }
}

#if DEBUG
#Preview {
    ChattingView(
        store: Store(initialState: ChattingViewFeature.State()) {
            ChattingViewFeature()
        }
    )
}
#endif
