//
//  ChallengeDetailView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/2/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct ChallengeDetailView: View {
    
    @Perception.Bindable var store: StoreOf<ChallengeDetailFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
        }
    }
}

extension ChallengeDetailView {
    
    private var contentView: some View {
        VStack(spacing: 0) {
            navigationView
                .padding(.bottom, 36)
            
            topImageUserStatusView
            
            ChallengeStatusThreeDayView
                .padding(.vertical, SpacingHelper.xl.pixel)
            
            informationView
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GBColor.background1.asColor)
    }
    
    private var navigationView: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image(uiImage: ImageHelper.back.image)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .asButton {
                            store.send(.viewEvent(.dismissTap))
                        }
                    Spacer()
                    
                    Text("멈추기")
                        .font(FontHelper.h3.font)
                        .foregroundStyle(GBColor.error.asColor)
                        .asButton {
                            store.send(.viewEvent(.stopTap))
                        }
                }
            }
            .padding(.horizontal, SpacingHelper.md.pixel)
            
            Text(store.entity.challengeTitle)
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.grey100.asColor)
        }
    }
    
    private var topImageUserStatusView: some View {
        VStack(spacing: 0) {
            Group {
                if let url = store.entity.imageURL {
                    DownImageView(url: url, option: .mid, fallbackURL: nil, fallBackImg: ImageHelper.appLogo.image)
                } else {
                    Image(uiImage: ImageHelper.appLogo.image)
                        .resizable()
                }
            }
            .frame(width: 160, height: 160)
            .padding(.bottom, SpacingHelper.md.pixel)
            
            Text("\(store.entity.userName)님은")
                .font(FontHelper.h4.font)
                .foregroundStyle(GBColor.white.asColor.opacity(0.5))
            
            Text(store.entity.dayCountWithStatus)
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
        }
    }
    
    private var ChallengeStatusThreeDayView: some View {
        HStack(spacing: SpacingHelper.xl.pixel) {
            ForEach(Array(store.entity.challengeStatus.enumerated()), id: \.element.id) { index, item in
                VStack (spacing: SpacingHelper.sm.pixel) {
                    switch item {
                    case .success:
                        ImageHelper.checkChecked.asImage
                            .resizable()
                            .frame(width: 55.5, height: 55.5)
                    case .fail:
                        ImageHelper.checkDisabled.asImage
                            .resizable()
                            .frame(width: 55.5, height: 55.5)
                    case .wait:
                        ImageHelper.checkEnabled.asImage
                            .resizable()
                            .frame(width: 55.5, height: 55.5)
                            .asButton {
                                store.send(.viewEvent(.selectedCaseItem(item: item)))
                            }
                    case .none:
                        ImageHelper.checkDisabled.asImage
                            .resizable()
                            .frame(width: 55.5, height: 55.5)
                    }
                    
                    Text("\(index + 1)일차")
                }
            }
        }
    }
    
    private var informationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ImageHelper.miniBurn.asImage
                    .resizable()
                    .frame(width: 16, height: 16)
                
                Text(store.entity.currentPeopleChallengeState)
                    .foregroundStyle(GBColor.white.asColor)
                    .font(FontHelper.body4.font)
            }
            
            HStack {
                ImageHelper.miniChallendar.asImage
                    .resizable()
                    .frame(width: 16, height: 16)
                Text(store.entity.weekAvgText)
                    .foregroundStyle(GBColor.white.asColor)
                    .font(FontHelper.body4.font)
            }
            
            HStack {
                ImageHelper.miniAward.asImage
                    .resizable()
                    .frame(width: 16, height: 16)
                Text(store.entity.fullDays)
                    .foregroundStyle(GBColor.white.asColor)
                    .font(FontHelper.body4.font)
            }
        }
        .padding(.all, SpacingHelper.md.pixel)
        .background {
            GBColor.grey400.asColor
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#if DEBUG
#Preview {
    ChallengeDetailView(store: Store(initialState: ChallengeDetailFeature.State(challengeID: "1"), reducer: {
        ChallengeDetailFeature()
    }))
}
#endif
