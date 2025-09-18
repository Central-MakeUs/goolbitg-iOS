//
//  SelectExpenditureDateViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/13/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Data

@Reducer
public struct ExpressExpenditureDateViewFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Hashable {
        public init () {}
        var selectedWeak: WeakEnum? = nil
        var selectedDate = Date()
    }
    
    public enum Action {
        case viewEvent(ViewEvent)
        case delegate(Delegate)
        
        public enum Delegate {
            case nextView
        }
        
        // Binding
        case selectedDate(Date)
    }
    
    public enum ViewEvent {
        case selectedWeak(WeakEnum)
        case nextButtonTapped
        case skipClicked
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.dateManager) var dateManager
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension ExpressExpenditureDateViewFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .viewEvent(.selectedWeak(let item)):
                state.selectedWeak = item
                
            case .viewEvent(.skipClicked):
                return .send(.delegate(.nextView))
             
            case .selectedDate(let date):
                state.selectedDate = date
                
            case .viewEvent(.nextButtonTapped):
                guard let currentWeek = state.selectedWeak else {
                    return .none
                }
                let currentDate = state.selectedDate
                let format = dateManager.format(format: .timeHHmmss, date: currentDate)
                return .run { send in
                    try await networkManager.requestNotDtoNetwork(
                        router: UserRouter.userPatternRegist(requestModel: UserPatternRequestModel(
                            primeUseDay: currentWeek.format,
                            primeUseTime: format )
                        ),
                        ifRefreshNeed: true
                    )
                    await send(.delegate(.nextView))
                } catch: { error, send in
                    Logger.error(error)
                }
                
            default:
                break
            }
            return .none
        }
    }
}
