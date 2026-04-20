//
//  TabNavigationCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/8/25.
//

import SwiftUI
import ComposableArchitecture
import FeatureCommon
import FeatureChallenge
import FeatureBuyOrNot
import FeatureMyPage

public struct TabNavigationCoordinatorView: View {
    
    public init(store: StoreOf<TabNavigationCoordinator>) {
        self.store = store
    }
    
    @Perception.Bindable var store: StoreOf<TabNavigationCoordinator>
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                GBTabBarView(store: store.scope(state: \.tabView, action: \.tabView))
            } destination: { store in
                switch store.state {
                case .chatView:
                    if let store = store.scope(state: \.chatView, action: \.chatView) {
                        ChattingView(store: store)
                            .navigationBarBackButtonHidden()
                            .disableBackGesture(false)
                    }

                case .buyOrNotAdd:
                    if let store = store.scope(state: \.buyOrNotAdd, action: \.buyOrNotAdd) {
                        BuyOrNotAddView(store: store)
                            .navigationBarBackButtonHidden()
                            .disableBackGesture(false)
                    }

                case .challengeAdd:
                    if let store = store.scope(state: \.challengeAdd, action: \.challengeAdd) {
                        ChallengeAddView(store: store)
                            .navigationBarBackButtonHidden()
                            .disableBackGesture(false)
                    }

                case .challengeDetail:
                    if let store = store.scope(state: \.challengeDetail, action: \.challengeDetail) {
                        ChallengeDetailView(store: store)
                            .navigationBarBackButtonHidden()
                            .disableBackGesture(false)
                    }

                case .pushHabitChart:
                    if let store = store.scope(state: \.pushHabitChart, action: \.pushHabitChart) {
                        HabitChartsView(store: store)
                            .navigationBarBackButtonHidden()
                            .disableBackGesture(false)
                    }

                case .groupChallengeDetail:
                    if let store = store.scope(state: \.groupChallengeDetail, action: \.groupChallengeDetail) {
                        ChallengeGroupDetailView(store: store)
                            .navigationBarBackButtonHidden()
                            .disableBackGesture(false)
                    }

                case .groupChallengeSetting:
                    if let store = store.scope(state: \.groupChallengeSetting, action: \.groupChallengeSetting) {
                        ChallengeGroupSettingView(store: store)
                            .navigationBarBackButtonHidden()
                            .disableBackGesture(false)
                    }

                case .groupChallengeModify:
                    if let store = store.scope(state: \.groupChallengeModify, action: \.groupChallengeModify) {
                        ChallengeGroupCreateView(store: store)
                            .navigationBarBackButtonHidden()
                            .disableBackGesture(false)
                    }
                }
            }
            .id("tab-shell-navigation-stack")
        }
    }
}
