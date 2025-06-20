//
//  MyPageApp.swift
//  MyPageApp
//
//  Created by Jae hyung Kim on 6/20/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import Data

@main
struct MyPageApp: App {
    var body: some Scene {
        WindowGroup {
            MyPageViewCoordinatorView(
                store: Store(
                    initialState: MyPageTabCoordinator.State.initialState,
                    reducer: {
                        MyPageTabCoordinator()
                    }
                )
            )
            .task {
                await RootLoginManager.login()
            }
        }
    }
}
