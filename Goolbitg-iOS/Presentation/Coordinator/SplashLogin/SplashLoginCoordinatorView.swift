//
//  SplashLoginCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/22/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct SplashLoginCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<SplashLoginCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            content
        }
    }
}

extension SplashLoginCoordinatorView {
    private var content: some View {
        VStack {
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .splash(store):
                    SplashView(store: store)
                    
                case let .login(store):
                    GBLoginView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                    
                case let .authRequestPage(store):
                    AuthPageView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                    
                case let .userInfoRequestView(store):
                    AuthRequestView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                    
                case let .analysisView(store):
                    AnalysisView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                    
                case let .shoppingCheckListView(store):
                    ShoppingCheckListView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                    
                case let .habitCheckView(store):
                    ComsumptionHabitsView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                
                case let .dayTimeCheckView(store):
                    SelectExpenditureDateView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                    
                case let .analyzingConsumption(store):
                    AnalyzingConsumptionView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                    
                case let .resultHabit(store):
                    ResultHabitView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                    
                case let .challengeAdd(store):
                    ChallengeAddView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }
            }
        }
    }
}

extension SplashLoginScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .login:
            return .login
        case .splash:
            return .splash
        case .authRequestPage:
            return .authRequestPage
        case .userInfoRequestView:
            return .userInfoRequestView
        case .analysisView:
            return .analysisView
        case .shoppingCheckListView:
            return .shoppingCheckListView
        case .habitCheckView:
            return .habitCheckListView
        case .dayTimeCheckView:
            return .exDayTimeCheckView
        case .analyzingConsumption:
            return .analyzingConsumption
        case .resultHabit:
            return .resultHabit
        case .challengeAdd:
            return .challengeAdd
        }
    }
    
    enum ID: Identifiable {
        case splash
        case login
        case authRequestPage
        case userInfoRequestView
        case analysisView
        case shoppingCheckListView
        case habitCheckListView
        case exDayTimeCheckView
        case analyzingConsumption
        case resultHabit
        case challengeAdd
        
        var id: ID {
            return self
        }
    }
}
