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
    @State private var moveToAppStoreTrigger = false
    
    @Environment(\.scenePhase) var scenePhase
    @Dependency(\.moveURLManager) var moveURLManager
    
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
                .onChange(of: moveToAppStoreTrigger) { _ in
                    moveURLManager.moveURL(caseOf: .appStore)
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
                .alert("앱 업데이트 필요", isPresented: $store.showAppStorePopup.sending(\.bindingAppStore)) {
                    Text("이동")
                        .asButton {
                            moveToAppStoreTrigger = true
                        }
                } message: {
                    Text("앱스토어로 이동합니다.")
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
