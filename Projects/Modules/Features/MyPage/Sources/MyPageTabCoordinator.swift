//
//  MyPageTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import Foundation
import ComposableArchitecture
import FeatureCommon

@Reducer
public struct MyPageTabCoordinator {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public static let initialState = State()

        var home = MyPageViewFeature.State()
        var revokePage: RevokeFeature.State?
        var pushList: PushListViewFeature.State?
    }
    
    public enum Action {
        case home(MyPageViewFeature.Action)
        case revokePage(RevokeFeature.Action)
        case pushList(PushListViewFeature.Action)
        case delegate(Delegate)
        
        public enum Delegate {
            case tabViewHidden
            case tabViewShow
            case moveToHabitChart
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            MyPageViewFeature()
        }
        core
            .ifLet(\.revokePage, action: \.revokePage) {
                RevokeFeature()
            }
            .ifLet(\.pushList, action: \.pushList) {
                PushListViewFeature()
            }
    }
}

extension MyPageTabCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .revokePage(.delegate(.dismiss)):
                state.revokePage = nil
                
            case .pushList(.delegate(.dismiss)):
                state.pushList = nil
                
            case .home(.delegate(.revokedEvent)):
                state.revokePage = RevokeFeature.State()
                
            case .home(.delegate(.pushButtonTapped)):
                state.pushList = PushListViewFeature.State()
            
            // MARK: 나의 소비 습관
            case .home(.delegate(.habitChartMoveTapped)):
                return .send(.delegate(.moveToHabitChart))
            default:
                break
            }
            return .none
        }
    }
}
