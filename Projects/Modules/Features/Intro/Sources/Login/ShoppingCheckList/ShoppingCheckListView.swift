//
//  ShoppingCheckListView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import SwiftUI
import ComposableArchitecture
import TipKit
import Utils
import FeatureCommon

struct ShoppingCheckListView: View {
    
    @Perception.Bindable var store: StoreOf<ShoppingCheckListViewFeature>
    
    @State private var isShowTitle: Bool = false
    @State private var viewButtonState: Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                if isShowTitle {
                    contentView
                        .padding(.top, SpacingHelper.xxl.pixel / 2)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            )
                        )
                        .animation(.easeInOut, value: store.isShowView)

                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .background(GBColor.background1.asColor)
            .onAppear {
                store.send(.viewCycle(.onAppear))
                withAnimation(.easeInOut(duration: 1.3)) {
                    isShowTitle = true
                }
            }
            .onChange(of: store.buttonState) { newValue in
                viewButtonState = newValue
            }
        }
    }
}

extension ShoppingCheckListView {
    
    private var contentView: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    headerView
                        .padding(.horizontal, 16)
                        .foregroundStyle(.clear)
                    
                    ZStack(alignment: .top) {
                        checkListView
                        
                        Rectangle()
                            .fill(
                                .linearGradient(colors: [
                                    GBColor.background1.asColor.opacity(1),
                                    GBColor.background1.asColor.opacity(0.7),
                                    GBColor.background1.asColor.opacity(0.4),
                                    GBColor.background1.asColor.opacity(0)
                                ], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: SpacingHelper.xl.pixel)
                            .allowsHitTesting(false)
                    }
                    
                    Spacer()
                }
                
            }
            if viewButtonState {
                nextButton
            }
        }
    }
    
    private var headerShadowView: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.horizontal, 16)
            
            VStack {}
                .frame(maxWidth: .infinity)
                .frame(height: SpacingHelper.xl.pixel)
                .background {
                    Rectangle()
                        .fill(
                            .linearGradient(colors: [
                                GBColor.background1.asColor.opacity(1),
                                GBColor.background1.asColor.opacity(0.7),
                                GBColor.background1.asColor.opacity(0.4),
                                GBColor.background1.asColor.opacity(0)
                            ], startPoint: .top, endPoint: .bottom)
                        )
                }
        }
    }
    
    private var headerView: some View {
        VStack (spacing: 0) {
            HStack {
                Text(TextHelper.shoppingCheckListHeaderTitle)
                    .font(FontHelper.h1.font)
                    .foregroundStyle(GBColor.white.asColor)
                
                Spacer()
            }
            .padding(.bottom, SpacingHelper.lg.pixel)
            
            HStack {
                Text(TextHelper.shoppingCheckListHeaderSub)
                    .font(FontHelper.body1.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                Spacer()
            }
            .padding(.bottom, 2)
            
            HStack( spacing: 1) {
                Text(TextHelper.shoppingCheckListPointText)
                    .font(FontHelper.h2.font)
                    .foregroundStyle(GBColor.main.asColor)

                Text(TextHelper.shoppingCheckListPointTrailingText)
                    .font(FontHelper.body1.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                
                Spacer()
            }
        }
    }
    
    private var checkListView: some View {
        
        ScrollView {
            VStack(spacing: SpacingHelper.md.pixel) {
                Color.clear
                    .padding(.bottom, SpacingHelper.lg.pixel)
                
                ForEach(Array(store.state.mockDatas.enumerated()), id: \.element.self) { index, data in
                    checkListElementView(data: data)
                        .asButton {
                            store.send(.viewEvent(.selectedCheckListElement(data: data, idx: index)))
                        }
                        .padding(.horizontal, 16)
                }
                
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .background(GBColor.background1.asColor)

    }
    
    private func checkListElementView(data: ShoppingCheckListViewFeature.MockData) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(uiImage: data.checkState ? ImageHelper.checked.image : ImageHelper.unChecked.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, SpacingHelper.md.pixel)
                
                Text(data.titel)
                    .font(FontHelper.btn3.font)
                    .foregroundStyle( data.checkState ? GBColor.main.asColor : GBColor.white.asColor )
                
                Spacer()
            }
            .padding(.all, SpacingHelper.md.pixel)
        }
        .background(data.checkState ? GBColor.main20.asColor : GBColor.grey700.asColor)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
        }
    }
    
    
    private var nextButton: some View {
        GBButton(
            isActionButtonState: $store.buttonState.sending(\.buttonState),
            title: TextHelper.nextTitle) {
                store.send(.viewEvent(.nextButtonTapped))
                
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
    }
    
}


#Preview {
    ShoppingCheckListView(store: Store(initialState: ShoppingCheckListViewFeature.State(), reducer: {
        ShoppingCheckListViewFeature()
    }))
}
