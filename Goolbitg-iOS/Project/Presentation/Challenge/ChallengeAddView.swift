//
//  ChallengeAddView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct ChallengeAddView: View {
    
    @Perception.Bindable var store: StoreOf<ChallengeAddViewFeature>
    
    private let skeletonBaseView = CommonChallengeListElementImageView(
        model: ChallengeEntity(
            id: UUID().uuidString,
            imageUrl: nil, imageUrlLarge: nil,
            title: "XXXXXXXXXXXXxxxxxxxxx",
            subTitle: "XXXXXXXXXXXXxxxxxxxxxxxx",
            reward: "",
            participantCount: "",
            avgAchiveRatio: "",
            maxAchiveDays: 0,
            status: nil
        ), next: false
    )
    
    var body: some View {
        WithPerceptionTracking {
            content
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
                .popup(item: $store.selectedEntity.sending(\.selectedEntityBinding)) { item in
                    GBChallengeBottomSheetView(
                        title: item.title,
                        subTitle: item.subTitle,
                        imageURL: item.imageUrlLarge,
                        bottomHashTag: nil,
                        buttonTitle: TextHelper.challengeTryTitle
                    ) {
                        store.send(.viewEvent(.tryButtonTapped(item: item)))
                    }
                } customize: {
                    $0
                        .type(.toast)
                        .animation(.spring)
                        .closeOnTapOutside(true)
                        .closeOnTap(false)
                        .backgroundColor(Color.black.opacity(0.5))
                }
                .popup(item: $store.alertComponents.sending(\.alertComponents)) { model in
                    GBAlertView(model: model) { }
                    okTouch: {
                        store.send(.alertComponents(nil))
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

        }
    }
}

extension ChallengeAddView {
    private var content: some View {
        VStack(spacing: 0) {
            navigationView
            
            ScrollView {
                headerView
                    .padding(.horizontal, SpacingHelper.lg.pixel)
                
                sameFamous
                    .padding(.horizontal, SpacingHelper.md.pixel)
                    .padding(.horizontal, SpacingHelper.sm.pixel)
                    .padding(.bottom, SpacingHelper.md.pixel)
                
                anotherList
                    .padding(.horizontal, SpacingHelper.md.pixel)
                    .padding(.horizontal, SpacingHelper.sm.pixel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GBColor.background1.asColor)
    }
    
    private var navigationView: some View {
        VStack(spacing: 0) {
            ZStack {
                if !store.dismissButtonHidden {
                    HStack(spacing: 0) {
                        Image(uiImage: ImageHelper.back.image)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .asButton {
                                store.send(.viewEvent(.dismissButtonTapped))
                            }
                        Spacer()
                    }
                }
                
                Text(TextHelper.challengeAddTitle)
                    .font(FontHelper.h3.font)
                    .foregroundStyle(GBColor.white.asColor)
            }
            .padding(.all, SpacingHelper.md.pixel)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            HStack(spacing: 0) {
                Text("\(UserDefaultsManager.userNickname)" + TextHelper.challengeWhatMakeTitle)
                    .font(FontHelper.h1.font)
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }
            
            HStack(spacing: 0) {
                Text(TextHelper.challengeChoiceWhatYouWantToHabitOne)
                    .font(FontHelper.body2.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                Spacer()
            }
        }
    }
    
    /// 같은 소비 유형 인기 챌린지
    private var sameFamous: some View {
        VStack(spacing: 0) {
            HStack( spacing:0 ) {
                Text(TextHelper.challengeSameFamousSpendingChallenge)
                    .font(FontHelper.h4.font)
                    .foregroundStyle(GBColor.white.asColor)
                
                Spacer()
            }
            famousList
        }
        .padding(.horizontal, SpacingHelper.md.pixel)
        .padding(.top, 16)
        .padding(.bottom, SpacingHelper.sm.pixel)
        .background(GBColor.grey600.asColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(GBColor.grey500.asColor)
        }
    }
    
    private var famousList : some View {
        LazyVStack {
            
            if let list = store.currentFamousList {
                ForEach(Array(list.enumerated()), id: \.element.self) { index, item in
                    VStack(spacing:0) {
                        famousListElementView(count: list.count, item: item, index: index)
                            .padding(.vertical, SpacingHelper.md.pixel)
                        
                        if index != list.count - 1 {
                            GBColor.grey500.asColor
                                .frame(maxWidth: .infinity)
                                .frame(height: 1)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: 1)
                        }
                    }
                    .asButton {
                        store.send(.viewEvent(.selectedChallenge(item)))
                    }
                }
            } else {
                SkeletonWrapper(count: 3) {
                    skeletonBaseView
                        .padding(.vertical, SpacingHelper.md.pixel)
                }
            }
        }
    }
    
    @ViewBuilder
    private func famousListElementView(count: Int, item: ChallengeEntity, index: Int) -> some View {
        let maxIndex = count
        let opacityValue = maxIndex > 0 ? 1.0 - (Double(index) / Double(maxIndex)) : 1.0
        
        HStack(spacing: 0) {
            /// Rank
            Text(String(index + 1))
                .font(FontHelper.h1.font)
                .foregroundStyle(GBColor.main.asColor.opacity(opacityValue))
                .padding(.trailing, 10)
            CommonChallengeListElementImageView(model: item, next: false)
                .padding(.trailing, SpacingHelper.sm.pixel)
        }
    }
    
    private var anotherList: some View {
        VStack(spacing:0) {
            HStack(spacing:0) {
                Text(TextHelper.challengeHowAboutAnotherHabitOne)
                    .font(FontHelper.h4.font)
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }
            
            LazyVStack {
                if let list = store.currentAnotherList {
                    ForEach(Array(list.enumerated()), id: \.element.self) { index, item in
                        VStack(spacing:0) {
                            CommonChallengeListElementImageView(model: item, next: false)
                                .padding(.vertical, SpacingHelper.md.pixel)
                            
                            if index != list.count - 1 {
                                GBColor.grey500.asColor
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 1)
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 1)
                            }
                        }
                        .asButton {
                            store.send(.viewEvent(.selectedChallenge(item)))
                        }
                    }
                } else {
                    SkeletonWrapper(count: 5) {
                        skeletonBaseView
                            .padding(.vertical, SpacingHelper.md.pixel)
                    }
                }
            }
        }
        .padding(.horizontal, SpacingHelper.md.pixel)
        .padding(.top, 16)
        .padding(.bottom, SpacingHelper.sm.pixel)
        .background(GBColor.grey600.asColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(GBColor.grey500.asColor)
        }
    }
    
}

#if DEBUG
#Preview {
    ChallengeAddView(store: Store(initialState: ChallengeAddViewFeature.State(dismissButtonHidden: true), reducer: {
        ChallengeAddViewFeature()
    }))
}
#endif
