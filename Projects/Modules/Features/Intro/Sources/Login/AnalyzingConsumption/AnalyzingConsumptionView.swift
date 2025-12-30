//
//  AnalyzingConsumptionView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import SwiftUI
import ComposableArchitecture
import Utils

struct AnalyzingConsumptionView: View {
    
    @Perception.Bindable var store: StoreOf<AnalyzingConsumptionFeature>
    
    var body: some View {
        WithPerceptionTracking {
            content
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
        }
    }
}

extension AnalyzingConsumptionView {
    private var content: some View {
        
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(TextHelper.analyzingConsumptionTitle)
                    .font(FontHelper.h1.font)
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }
            .padding(.horizontal, SpacingHelper.sm.pixel)
            .padding(.bottom, SpacingHelper.lg.pixel)
            
            HStack(spacing: 0) {
                Text(TextHelper.analyzingConsumptionSubTitle)
                    .font(FontHelper.body1.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                Spacer()
            }
            .padding(.horizontal, SpacingHelper.sm.pixel)
            
            Image(uiImage: ImageHelper.appLogo.image)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, SpacingHelper.lg.pixel)
        .padding(.horizontal, SpacingHelper.md.pixel)
        .background(GBColor.background1.asColor)
    }
}

#if DEBUG
#Preview {
    AnalyzingConsumptionView(store: Store(initialState: AnalyzingConsumptionFeature.State(), reducer: {
        AnalyzingConsumptionFeature()
    }))
}
#endif
