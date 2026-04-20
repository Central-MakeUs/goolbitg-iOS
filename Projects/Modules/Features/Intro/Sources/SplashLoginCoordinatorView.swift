//
//  SplashLoginCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/22/25.
//

import SwiftUI
import ComposableArchitecture
import FeatureCommon

public struct SplashLoginCoordinatorView: View {
    
    @Perception.Bindable public var store: StoreOf<SplashLoginCoordinator>
    
    public init(store: StoreOf<SplashLoginCoordinator>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            content
        }
    }
}

extension SplashLoginCoordinatorView {
    private var content: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            SplashView(store: store.scope(state: \.splash, action: \.splash))
        } destination: { store in
            switch store.state {
            case .login:
                if let store = store.scope(state: \.login, action: \.login) {
                    GBLoginView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }

            case .authRequestPage:
                if let store = store.scope(state: \.authRequestPage, action: \.authRequestPage) {
                    AuthPageView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }

            case .userInfoRequestView:
                if let store = store.scope(state: \.userInfoRequestView, action: \.userInfoRequestView) {
                    AuthRequestView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }

            case .analysisView:
                if let store = store.scope(state: \.analysisView, action: \.analysisView) {
                    AnalysisView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }

            case .shoppingCheckListView:
                if let store = store.scope(state: \.shoppingCheckListView, action: \.shoppingCheckListView) {
                    ShoppingCheckListView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }

            case .habitCheckView:
                if let store = store.scope(state: \.habitCheckView, action: \.habitCheckView) {
                    ComsumptionHabitsView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }

            case .dayTimeCheckView:
                if let store = store.scope(state: \.dayTimeCheckView, action: \.dayTimeCheckView) {
                    SelectExpenditureDateView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }

            case .analyzingConsumption:
                if let store = store.scope(state: \.analyzingConsumption, action: \.analyzingConsumption) {
                    AnalyzingConsumptionView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }

            case .resultHabit:
                if let store = store.scope(state: \.resultHabit, action: \.resultHabit) {
                    ResultHabitView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }

            case .challengeAdd:
                if let store = store.scope(state: \.challengeAdd, action: \.challengeAdd) {
                    ChallengeAddView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }
            }
        }
    }
}
