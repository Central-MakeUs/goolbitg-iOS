//
//  ChallengeApp.swift
//  ChallengeApp
//
//  Created by Jae hyung Kim on 5/26/25.
//

import SwiftUI
import ComposableArchitecture
import Data

@main
struct HomeApp: App {
    
    var body: some Scene {
        WindowGroup {
            ChallengeTabCoordinatorView(
                store: Store(initialState: ChallengeTabCoordinator.State.initialState, reducer: {
                    ChallengeTabCoordinator()
            }))
            .task {
                await RootLoginManager.login()
            }
        }
    }
}
