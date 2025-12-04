//
//  IntroApp.swift
//  IntroApp
//
//  Created by Jae hyung Kim on 12/4/25.
//

import SwiftUI
import ComposableArchitecture
import Data

@main
struct MyPageApp: App {
    var body: some Scene {
        WindowGroup {
            SplashLoginCoordinatorView(
                store: Store(initialState: SplashLoginCoordinator.State.initialState, reducer: {
                    SplashLoginCoordinator()
                })
            )
            .task {
                await RootLoginManager.login()
            }
        }
    }
}
