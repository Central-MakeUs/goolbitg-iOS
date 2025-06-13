//
//  ChallengeApp.swift
//  ChallengeApp
//
//  Created by Jae hyung Kim on 5/26/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct HomeApp: App {
    
    var body: some Scene {
        WindowGroup {
//            ChallengeTabCoordinatorView(
//                store: Store(initialState: ChallengeTabCoordinator.State.initialState, reducer: {
//                    ChallengeTabCoordinator()
//            }))
//            .onAppear {
//                
//            }
            ChallengeGroupDetailView()
        }
    }
}
