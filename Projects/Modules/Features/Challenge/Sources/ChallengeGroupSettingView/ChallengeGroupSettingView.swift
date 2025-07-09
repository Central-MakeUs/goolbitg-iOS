//
//  ChallengeGroupSettingView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 7/9/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView
import Utils
import FeatureCommon

struct ChallengeGroupSettingView: View {
    
    @Perception.Bindable var store: StoreOf<ChallengeGroupSettingViewFeature>
    
    var body: some View {
        WithPerceptionTracking {
            content
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
                .popup(item: $store.alertComponent.sending(\.alertBinding)) { component in
                    GBAlertView(model: component) {
                        store.send(.viewEvent(.alertCancelTapped(component.ifNeedID)))
                    } okTouch: {
                        store.send(.viewEvent(.alertOkTapped(component.ifNeedID)))
                    }
                } customize: {
                    $0
                        .animation(.easeInOut)
                        .type(.default)
                        .displayMode(.sheet)
                        .appearFrom(.centerScale)
                        .closeOnTap(false)
                        .closeOnTapOutside(false)
                        .backgroundColor(Color.black.opacity(0.5))
                }
        }
    }
}

extension ChallengeGroupSettingView {
    private var content: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.horizontal, SpacingHelper.md.pixel)
            
            settingListView
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.top, SpacingHelper.lg.pixel)
            
            if store.ifOwner {
                ownerOnlyMessageView
                    .padding(.horizontal, SpacingHelper.md.pixel)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GBColor.background1.asColor)
    }
    
    private var navigationBar: some View {
        ZStack(alignment: .center) {
            Text(TextHelper.groupChallengeTexts(.settingNavTitle).text)
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
            
            HStack {
                ImageHelper.back.asImage
                    .resizable()
                    .frame(width: 32, height: 32)
                    .asButton {
//                        store.send(.viewAction(.tappedDismiss))
                        store.send(.delegate(.back))
                    }
                Spacer()
            }
        }
    }
    
    
    public var settingListView: some View {
        VStack(spacing: 0) {
            ForEach(Array(ChallengeGroupSettingViewFeature.ChallengeSettings.allCases.enumerated()), id: \.element.self) { index, caseOf in
                switch caseOf {
                case .alertSetting:
                    HStack(alignment: .center ,spacing:0) {
                        Text(caseOf.title)
                            .font(FontHelper.caption1.font)
                            .foregroundStyle(GBColor.white.asColor)
                        
                        Spacer()
                        
                        OnOffSwitchView(buttonState: $store.currentAlertState.sending(\.currentAlertState))
                    }
                    .padding(.horizontal, SpacingHelper.sm.pixel)
                    .padding(.vertical, SpacingHelper.md.pixel)
                case .roomInfoModify :
                    if store.ifOwner {
                        HStack(alignment: .center ,spacing:0) {
                            Text(caseOf.title)
                                .font(FontHelper.caption1.font)
                                .foregroundStyle(GBColor.white.asColor)
                            
                            Spacer()
                            
                            ImageHelper.right.asImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 12)
                        }
                        .padding(.horizontal, SpacingHelper.sm.pixel)
                        .padding(.vertical, SpacingHelper.md.pixel)
                        .background(GBColor.background1.asColor)
                        .asButton {
                            store.send(.viewEvent(.tappedModifyRoomSetting))
                        }
                    }
                }
                
                if index != ChallengeGroupSettingViewFeature.ChallengeSettings.allCases.count - 1 {
                    GBColor.grey500.asColor
                        .frame(height: 1)
                }
            }
        }
    }
    
    private var ownerOnlyMessageView: some View {
        VStack(spacing: 0) {
            
            if store.deleteButtonState {
                deleteButtonView
                    .asButton {
                        store.send(.viewEvent(.tappedRoomDelete))
                    }
            } else {
                deleteButtonView
                    .overlay {
                        GBColor.background1.asColor
                            .opacity(0.6)
                    }
            }
            
            HStack(spacing: 0) {
                ImageHelper.warning.asImage
                    .resizable()
                    .frame(width: 32, height: 32)
                
                Text(TextHelper.groupChallengeTexts(.onlyOneParticipantDeleteWarning).text)
                    .foregroundStyle(GBColor.grey300.asColor)
                    .font(FontHelper.body5.font)
            }
        }
    }
    
    private var deleteButtonView: some View {
        VStack {
            Text(TextHelper.groupChallengeTexts(.groupChallengeDelete).text)
                .foregroundStyle(GBColor.grey300.asColor)
                .font(FontHelper.btn3.font)
                .padding(SpacingHelper.lg.pixel)
        }
        .frame(maxWidth: .infinity)
        .background(GBColor.background1.asColor)
        .clipShape(Capsule())
        .background {
            Capsule()
                .stroke(lineWidth: 1)
                .foregroundStyle(GBColor.grey300.asColor)
        }
        
    }
}

#if DEBUG
#Preview {
    ChallengeGroupSettingView(store: Store(initialState: ChallengeGroupSettingViewFeature.State(
        ifOwner: true,
        roomID: ""
    ), reducer: {
        ChallengeGroupSettingViewFeature()
    }))
}
#endif

