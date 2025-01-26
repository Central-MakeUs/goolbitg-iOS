//
//  AnalysisView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/18/25.
//

import SwiftUI
import ComposableArchitecture

struct AnalysisView: View {
    
    @Perception.Bindable var store: StoreOf<AnalysisFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentsView
        }
    }
}

extension AnalysisView {
    private var contentsView: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.top, SpacingHelper.xxl.pixel / 4)
                .padding(.horizontal, 24)
                .background(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0),
                            Color.black.opacity(0.14),
                            Color.black.opacity(0.2),
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.7),
                            Color.black.opacity(0.8)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            Spacer()
            StartButton
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            GIFImageView(imageName: "TestG.gif")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("\(UserDefaultsManager.userNickname)님의\n소비유형검사가 있어요")
                    .font(FontHelper.h1.font)
                
                Spacer()
            }
            .padding(.bottom, SpacingHelper.lg.pixel)
            HStack(spacing: 0) {
                Text("습관형성을 위한\n소비 유형 검사부터 시작해볼까요?")
                    .font(FontHelper.body1.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                Spacer()
            }
            VStack{}
                .frame(height: 20)
        }
    }
    
    private var StartButton: some View {
        VStack(spacing: 0) {
            HStack {
                Text(TextHelper.authStart)
                    .font(FontHelper.btn1.font)
                    .foregroundStyle(GBColor.grey600.asColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .background {
            GBColor.white.asColor
        }
        .clipShape(Capsule())
        .padding(.horizontal, 16)
        .asButton {
            store.send(.startButtonTapped)
        }
    }
}
