//
//  ChallengeGroupDetailView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 6/9/25.
//

import SwiftUI
import ComposableArchitecture
import Utils
import Data
import FeatureCommon

struct ChallengeGroupDetailView: View {
    
    // MARK: UI Member
    @Environment(\.safeAreaInsets) private var safeArea
    @State private var currentOffset: CGFloat = 0
    @State private var bottomSheetExpended: Bool = false
    
    // MARK: Feature
    @Perception.Bindable var store: StoreOf<ChallengeGroupDetailViewFeature>
    
    public var body: some View {
        WithPerceptionTracking {
            contentView
                .onPreferenceChange(ScrollOffsetKey.self) { offsetY in
                    currentOffset = offsetY
                }
                .background(GBColor.main.asColor)
                .dragBottomSheet(collapsedHeight: 36 + safeArea.bottom, isExpanded: $bottomSheetExpended) {
                    bottomSheetView()
                }
                .onFirstAppear {
                    store.send(.viewCycle(.onAppear))
                }
                .popup(item: $store.showErrorMessage.sending(\.showErrorMessage)) { message in
                    GBAlertView(model: .init(title: "ERROR", message: message, okTitle: "확인", alertStyle: .warning)) {}
                    okTouch: {
                        store.send(.showErrorMessage(message: nil))
                    }
                }
                
        }
        
    }
}

extension ChallengeGroupDetailView {
    
    private var contentView: some View {
        ZStack(alignment: .top) {
            
            GBColor.main.asColor
                .frame(height: calculateHeight())
                .zIndex(1)
                .offset(y: -5)
            
            ScrollView {
                VStack (spacing: 0) {
                    if store.topPodiumModels.count == 3 {
                        VStack (spacing: 0) {
                            ScrollViewOffsetPreference { offsetY in
                                currentOffset = offsetY
                            }
                            ChallengeProfilePodiumView(challengers: store.topPodiumModels)
                                .padding(.horizontal, calcTopPodiumHorizontalPadding())
                        }
                        .padding(.top, 64)
                        .padding(.top, safeArea.top)
                        .background(GBColor.main.asColor)
                        .cornerRadiusCorners(40, corners: [.bottomLeft, .bottomRight])
                        .background(GBColor.background1.asColor)
                    }
                    
                    bottomListView
                        .padding(.vertical, SpacingHelper.md.pixel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GBColor.background1.asColor)
            .zIndex(0)
            
            navigationView
                .zIndex(2)
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var navigationView: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 0) {
                    Image(uiImage: ImageHelper.back.image)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .asButton {
                            store.send(.delegate(.back))
                        }
                    Spacer()
                }
                
                Text(store.challengeEntityState.title)
                    .font(FontHelper.h3.font)
                    .foregroundStyle(GBColor.white.asColor)
                
                HStack(spacing: 0) {
                    Spacer()
                    Image(uiImage: ImageHelper.settingBtn.image)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .asButton {
                            store.send(.viewEvent(.settingButtonTapped))
                        }
                        .opacity(store.ifOwner ? 1 : 0)
                }
            }
            .frame(height: 64)
            .padding(.horizontal, SpacingHelper.md.pixel)
            .padding(.top, safeArea.top)
            .background {
                BlurView(style: .dark)
                    .opacity(calcNavOpacity())
            }
        }
    }
    
    private var bottomListView: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(store.bottomListModels.enumerated()), id: \.element.modelID) { index, model in
                listElementView(entity: model, rank: index + 4)
                    .padding(.bottom, SpacingHelper.sm.pixel)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, SpacingHelper.md.pixel)
    }
    
    private func listElementView(entity: ChallengeRankEntity, rank: Int) -> some View {
        VStack {
            HStack(spacing: 0) {
                Text(String(rank))
                    .foregroundStyle(GBColor.grey200.asColor)
                    .font(FontHelper.h3.font)
                
                DownImageView(url: URL(string: entity.imageURL ?? ""), option: .mid)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 54, height: 54)
                    .clipShape(Circle())
                    .padding(.leading, SpacingHelper.sm.pixel * 2 + 9)
                    .padding(.trailing, SpacingHelper.md.pixel)
                
                Text(entity.name)
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.white.asColor)
                
                Spacer()
                
                Text("+" + entity.priceText)
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.main.asColor)
            }
            .padding(.vertical, SpacingHelper.sm.pixel)
            .padding(.horizontal, SpacingHelper.md.pixel + 10)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(GBColor.grey500.asColor)
            }
        }
    }
}

// MARK: BottomSheetView
extension ChallengeGroupDetailView {
    
    private func bottomSheetView() -> some View {
        VStack {
            Capsule()
                .foregroundStyle(GBColor.grey400.asColor)
                .frame(width: 32, height: 4)
                .padding(.top, 16)
            
            VStack(spacing: 8) {
                VStack(spacing: 0) {
                    Text(store.challengeEntityState.title)
                        .foregroundStyle(GBColor.grey50.asColor)
                        .font(FontHelper.h3.font)
                }
                .opacity(bottomSheetExpended ? 1 : 0)
                .animation(.easeInOut, value: bottomSheetExpended)
                
                Text(store.challengeEntityState.hashTags.joined(separator: " "))
                    .lineLimit(2)
                    .lineSpacing(4)
                    .foregroundStyle(GBColor.white.asColor)
                    .font(FontHelper.body5.font)
                
                HStack(spacing: 0) {
                    Text("3일 연속 성공 시")
                        .foregroundStyle(GBColor.grey200.asColor)
                        .font(FontHelper.body4.font)
                    Text(" \("\(store.challengeEntityState.reward)")원 절약")
                        .foregroundStyle(GBColor.grey200.asColor)
                        .font(FontHelper.body3.font)
                }
                
                HStack {
                    ImageHelper.group.asImage
                        .resizable()
                        .frame(width: 12, height: 12)
                    
                    Text("\(store.challengeEntityState.totalWithParticipatingPeopleCount) 참여 완료")
                        .font(FontHelper.body3.font)
                        .foregroundStyle(GBColor.main.asColor)
                }
                .padding(.vertical, SpacingHelper.sm.pixel)
                
                ChallengeStatusThreeDayView
            }
            .padding(.horizontal, 46)
            .padding(.vertical, 16)
            .border(width: 1, edges: [.bottom], color: GBColor.grey500.asColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, safeArea.bottom)
        .background(GBColor.grey600.asColor)
        .cornerRadiusCorners(28, corners: [.topLeft, .topRight])
    }
    
    private var ChallengeStatusThreeDayView: some View {
        HStack(spacing: SpacingHelper.xl.pixel) {
            ForEach(Array(store.challengeStatus.enumerated()), id: \.element.id) { index, item in
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
//                                store.send(.viewEvent(.selectedCaseItem(item: item)))
                            }
                    case .none:
                        ImageHelper.checkDisabled.asImage
                            .resizable()
                            .frame(width: 55.5, height: 55.5)
                    }
                    
                    Text("\(index + 1)일차")
                        .foregroundStyle(GBColor.grey100.asColor)
                }
            }
        }
    }
}

// MARK: UI Calc Logic
extension ChallengeGroupDetailView {
    private func calculateHeight() -> CGFloat {
        let topNavigationHeight: CGFloat = 64
        
        let calc = currentOffset - topNavigationHeight
        
        let result = max(0, min(calc, UIScreen.main.bounds.height))
        
        print(result)
        
        return result
    }
    
    private func calcTopPodiumHorizontalPadding() -> CGFloat {
        let maxOffset: CGFloat = safeArea.top
        let clampedOffset = min(max(-currentOffset + maxOffset, 0), maxOffset)
        let progress = clampedOffset / maxOffset
        let padding: CGFloat = 40
        
        let calc = padding * ( 1 - progress )
#if DEBUG
        print("Current -> ",currentOffset)
        print("->",calc)
#endif
        return calc
    }
    
    private func calcNavOpacity() -> CGFloat {
        let maxOffset: CGFloat = safeArea.top
        let clampedOffset = min(max(-currentOffset, 0), maxOffset)
        let progress = clampedOffset / maxOffset // 0.0 ~ 1.0 사이 값
        return progress
    }
}

#if DEBUG
#Preview {
    ChallengeGroupDetailView(
        store: Store(
            initialState: ChallengeGroupDetailViewFeature.State(
                groupID: "1"
            ), reducer: {
        ChallengeGroupDetailViewFeature()
    }))
}
#endif
