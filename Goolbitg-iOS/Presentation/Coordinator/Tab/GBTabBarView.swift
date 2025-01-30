//
//  GBTabBarView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/27/25.
//

import SwiftUI
import ComposableArchitecture

struct GBTabBarView: View {
    
    @Perception.Bindable var store: StoreOf<GBTabBarCoordinator>
    
    private var rows: [GridItem] = Array(repeating: GridItem(.flexible()), count: TabCase.allCases.count)
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    init(store: StoreOf<GBTabBarCoordinator>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            contentView
        }
    }
}

extension GBTabBarView {
    private var contentView: some View {
        VStack(spacing: 0) {
            customTabBarView
        }
    }
}

extension GBTabBarView {
    private var customTabBarView: some View {
        TabView(selection: $store.currentTab.sending(\.currentTab)) {
            scopeView
        }
        .toolbar(.hidden, for: .tabBar)
        .overlay(alignment: .bottom) {
            customTabView
                
        }
        .ignoresSafeArea(edges: .bottom)
        .background(Color.red)
    }
    
    private var scopeView: some View {
        Group {
            HomeTabCoordinatorView(
                store: store.scope(state: \.homeTabState, action: \.homeTabAction)
            )
            .tag(TabCase.homeTab)
            
            ChallengeTabCoordinatorView(
                store: store.scope(state: \.chalengeTabState, action: \.challengeTabAction)
            )
            .tag(TabCase.ChallengeTab)
        }
    }
    
    private var customTabView: some View {
        VStack {
            LazyVGrid(columns: rows) {
                ForEach(TabCase.allCases, id: \.self) { caseOf in
                    tabItemView(tabItem: caseOf)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .fixedSize()
                        .asButton {
                            HapticFeedbackManager.shared.impact(style: .soft)
                            store.send(.currentTab(caseOf))
                        }
                }
            }
        }
        .padding(.top, 10)
        .padding(.bottom, safeAreaInsets.bottom + 8)
        .padding(.horizontal, 20)
        .background(GBColor.grey600.asColor)
        .cornerRadiusCorners(24, corners: [.topLeft, .topRight])
        .overlay {
            RoundedCornerShape(corners: [.topLeft, .topRight], radius: 24)
                .stroke(lineWidth: 1)
                .foregroundStyle(GBColor.grey300.asColor)
        }
        .frame(width: UIScreen.main.bounds.width + 2)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .clear

            // 경계선(검정색 줄) 제거
            appearance.shadowImage = UIImage()
            appearance.backgroundImage = UIImage()
            appearance.shadowColor = .clear

            // 설정 적용
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .offset(y: 1)
       
    }
    
    private func tabItemView(tabItem: TabCase) -> some View {
        let current = store.currentTab
        let this = tabItem
        let same = current == this
        return VStack(spacing: 0) {
            Group {
                switch tabItem {
                case .homeTab:
                    ImageHelper.homeTab.asImage
                        .renderingMode(.template)
                        .resizable()
                case .ChallengeTab:
                    ImageHelper.challengeTab.asImage
                        .renderingMode(.template)
                        .resizable()
                case .buyOrNotTab:
                    ImageHelper.buyOrNotTab.asImage
                        .renderingMode(.template)
                        .resizable()
                case .myPageTab:
                    ImageHelper.myPageTab.asImage
                        .renderingMode(.template)
                        .resizable()
                }
            }
            .frame(width: 24, height: 24)
            .foregroundStyle( same ? GBColor.main.asColor : GBColor.grey400.asColor )
            .padding(.bottom, 4)
            
            Text(this.title)
                .font( same ? PretendardFont.semiFont.asFont(size: 12) : FontHelper.body5.font)
                .foregroundStyle( same ? GBColor.main.asColor : GBColor.grey400.asColor )
        }
    }
    
}

#if DEBUG
#Preview {
    GBTabBarView(store: Store(initialState: GBTabBarCoordinator.State(), reducer: {
        GBTabBarCoordinator()
    }))
}
#endif
