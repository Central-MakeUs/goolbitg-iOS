//
//  GBTabBarView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/27/25.
//

import SwiftUI
import ComposableArchitecture

struct GBTabBarView: View {
    
    enum TabBarCase {
        case home
    }
    
    @State private var tabCase = TabBarCase.home
    
    var body: some View {
        WithPerceptionTracking {
            contentView
        }
    }
}

extension GBTabBarView {
    private var contentView: some View {
        VStack(spacing: 0) {
            TabView(selection: $tabCase) {
                
            }
            .toolbar(.hidden, for: .tabBar)
            .overlay {
                customTabBarView
            }
        }
    }
}

extension GBTabBarView {
    private var customTabBarView: some View {
        VStack(spacing: 0) {
            
        }
        .background(Color.red)
    }
}

#if DEBUG
#Preview {
    GBTabBarView()
}
#endif
