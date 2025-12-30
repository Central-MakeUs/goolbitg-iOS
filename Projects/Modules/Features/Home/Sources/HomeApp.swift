//
//  HomeApp.swift
//  FeatureHome
//
//  Created by Jae hyung Kim on 5/26/25.
//

import SwiftUI
import SwiftUI
import ComposableArchitecture
import Utils
import SwiftyBeaver
import Data

@main
struct HomeApp: App {
    
    var body: some Scene {
        WindowGroup {
            HomeTabCoordinatorView(store: Store(
                initialState: HomeTabCoordinator.State.initialState,
                reducer: {
                    HomeTabCoordinator()
                })
            )
            .task {
                await RootLoginManager.login()
            }
        }
    }
}

