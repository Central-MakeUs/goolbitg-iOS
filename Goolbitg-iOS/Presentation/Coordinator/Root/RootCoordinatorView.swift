//
//  RootCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import PopupView

struct RootCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<RootCoordinator>
    
    @State private var currentView: RootCoordinator.ChangeRootView = .splashLogin
    @State private var currentLoading = false
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        WithPerceptionTracking {
            content
                .onAppear {
                    store.send(.onAppear)
                }
                .onChange(of: store.currentView) { newValue in
                    withAnimation {
                        currentView = newValue
                    }
                }
                .popup(item: $store.alertItem.sending(\.alertItem)) { item in
                    GBAlertView(
                        model: item) {
                            store.send(.alertItem(nil))
                        } okTouch: {
                            store.send(.confirmCase(item))
                        }
                }
                .onChange(of: scenePhase) { newValue in
                    switch newValue {
                    case .background:
                        break
                    case .inactive:
                        break
                    case .active:
                        store.send(.onAppearFromBackground)
                    @unknown default:
                        break
                    }
                }
                .onReceive(LoadingEnvironment.shared.isLoading) { output in
                    currentLoading = output
                }
        }
    }
}


extension RootCoordinatorView {
    private var content: some View {
        ZStack {
            VStack {
                switch currentView {
                case .splashLogin:
                    SplashLoginCoordinatorView(
                        store: store.scope(
                            state: \.splashLogin,
                            action: \.splashLoginAction
                        )
                    )
                    
                case .mainTab:
                    TabNavigationCoordinatorView(
                        store: store.scope(
                            state: \.tabState,
                            action: \.tabAction
                        )
                    )
                }
            }
            
            if currentLoading {
                GBLoadingView()
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: currentLoading)
    }
}


#Preview {
    RootCoordinatorView(store: Store(
        initialState: RootCoordinator.State(),
        reducer: {
            RootCoordinator()
        }))
}
