//
//  ShoppingCheckListViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation
import ComposableArchitecture
import Domain
import Utils
import Data

@Reducer
public struct ShoppingCheckListViewFeature: GBReducer {
    
    public struct MockData: Equatable, Hashable {
        var checkState: Bool
        let titel: String
    }
    
    @ObservableState
    public struct State: Equatable, Hashable {
        var isShowView: Bool = false
        var buttonState: Bool = false
        
        var mockDatas: [MockData] = setMockData()
        let removeIdx = 5
        static func setMockData() -> [MockData] {
            [
                MockData(checkState: false, titel: TextHelper.checkList1),
                MockData(checkState: false, titel: TextHelper.checkList2),
                MockData(checkState: false, titel: TextHelper.checkList3),
                MockData(checkState: false, titel: TextHelper.checkList4),
                MockData(checkState: false, titel: TextHelper.checkList5),
                MockData(checkState: false, titel: TextHelper.checkList7)
            ]
        }
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case delegate(Delegate)
        
        public enum Delegate {
            case nextView
        }
        
        /// Binding
        case buttonState(Bool)
        
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum ViewEvent {
        case selectedCheckListElement(data: MockData, idx: Int)
        case nextButtonTapped
    }
    
    @Dependency(\.networkManager) var networkManager
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension ShoppingCheckListViewFeature {
    
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                state.isShowView = true
                
            case .viewEvent(.selectedCheckListElement( _, let idx)):
                if idx == state.removeIdx {
                    var reset = State.setMockData()
                    reset[idx].checkState = true
                    state.mockDatas = reset
                }
                else {
                    state.mockDatas[idx].checkState.toggle()
                    state.mockDatas[state.removeIdx].checkState = false
                }
                checkButtonState(state: &state)
                
                // buttonState
            case .buttonState(let bool):
                state.buttonState = bool
                
            case .viewEvent(.nextButtonTapped):
                var checks: [String: Bool] = [:]
                
                for (index, data) in state.mockDatas.enumerated() {
                    checks["check\(index + 1)"] = data.checkState
                }
                return .run { [checks] send in
                    try await networkManager.requestNotDtoNetwork(
                        router: UserRouter.userCheckList(
                            reqeustModel: CheckPayload(checks: checks)
                        ),
                        ifRefreshNeed: true
                    )
                    await send(.delegate(.nextView))
                } catch: { error, send in
                    Logger.error(error)
                }
            default :
                break
            }
            return .none
        }
    }
    
    private func checkButtonState(state: inout State) {
        let checked = state.mockDatas.filter {
            $0.checkState == true
        }
        let checkResult = !checked.isEmpty
        state.buttonState = checkResult
    } 
}
