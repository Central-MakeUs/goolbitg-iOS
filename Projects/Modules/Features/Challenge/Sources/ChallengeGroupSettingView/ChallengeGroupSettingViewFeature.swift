//
//  ChallengeGroupSettingViewFeature.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 7/9/25.
//

import Foundation
import ComposableArchitecture
import Domain
import Utils
import Data

@Reducer
public struct ChallengeGroupSettingViewFeature: GBReducer {
    
    @ObservableState
    public struct State: Equatable, Hashable {
        var onAppearTrigger = false
        let ifOwner: Bool
        let roomID: String
        var deleteButtonState = false
        var currentServerLoad = false
        var currentAlertState = false
        var alertComponent: GBAlertViewComponents? = nil
        
        public init(
            ifOwner: Bool,
            roomID: String
        ) {
            self.ifOwner = ifOwner
            self.roomID = roomID
        }
    }
    
    public enum Action {
        case currentAlertState(Bool)
        case viewEvent(ViewEvent)
        case viewCycle(ViewCycle)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        
        case alertBinding(GBAlertViewComponents?)
    }
    
    public enum ViewEvent {
        case tappedModifyRoomSetting
        case tappedRoomDelete
        
        case alertOkTapped(String)
        case alertCancelTapped(String)
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum FeatureEvent {
        case showAlert(AlertID)
        case requestRoomDelete
        case requestChallengeRoomInfo
        case buttonStateUpdate(Bool)
    }
    
    public enum Delegate {
        case removeSuccess
        case back
    }
    
    public enum AlertID: String {
        case deleteRoom
        case deleteFail
    }
    
    public enum ChallengeSettings: Equatable, CaseIterable {
        case roomInfoModify
        case alertSetting
        
        var title: String {
            switch self {
            case .roomInfoModify:
                return "작심삼일 방 정보 수정"
            case .alertSetting:
                return "알림 설정"
            }
        }
    }
    
    @Dependency(\.networkManager) var networkManager

    public var body: some ReducerOf<Self> {
        core
    }
}

extension ChallengeGroupSettingViewFeature {
    
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                if state.onAppearTrigger {
                    return .none
                }
                state.onAppearTrigger = true
                
                return .run { action in
                    // MARK: FIX ME - 알림 설정 부분이 필요함 서버측 작업이 없음
                    
                    await action(.featureEvent(.requestChallengeRoomInfo))
                }
                
            case .viewEvent(.tappedRoomDelete):
                return .send(.featureEvent(.showAlert(.deleteRoom)))
                
            case let .viewEvent(.alertOkTapped(id)):
                guard let id = AlertID(rawValue: id) else {
                    return .send(.alertBinding(nil))
                }
                
                switch id {
                case .deleteRoom:
                    return .run { send in
                        await send(.alertBinding(nil))
                        await send(.featureEvent(.requestRoomDelete))
                    }
                case .deleteFail:
                    return .send(.alertBinding(nil))
                }
                
            case let .viewEvent(.alertCancelTapped(id)):
                guard let id = AlertID(rawValue: id) else {
                    return .send(.alertBinding(nil))
                }
                switch id {
                case .deleteRoom:
                    return .send(.alertBinding(nil))
                case .deleteFail:
                    return .send(.alertBinding(nil))
                }
                
            case let .featureEvent(.showAlert(id)):
                let component: GBAlertViewComponents
                switch id {
                case .deleteRoom:
                    component = GBAlertViewComponents(
                        title: "작심삼일 방 삭제",
                        message: "작심삼일 방을\n정말 삭제하시겠어요?",
                        cancelTitle: "취소",
                        okTitle: "삭제",
                        alertStyle: .warning,
                        ifNeedID: id.rawValue
                    )
                case .deleteFail:
                    component = GBAlertViewComponents(
                        title: "삭제 실패",
                        message: "삭제를 실패 하였습니다.(네트워크 혹은 이미 삭제됨)",
                        okTitle: "확인",
                        alertStyle: .warning,
                        ifNeedID: id.rawValue
                    )
                }
                
                return .send(.alertBinding(component))
                
            case .featureEvent(.requestChallengeRoomInfo):
                let groupID = state.roomID
                return .run { send in
                    guard let result = try? await networkManager.requestNetworkWithRefresh(
                        dto: GroupChallengeDetailDTO.self,
                        router: ChallengeRouter.groupChallengeDetail(groupID: groupID)
                    ) else {
                        await send(.delegate(.back))
                        return
                    }
                  
                    await send(.featureEvent(.buttonStateUpdate(result.group.peopleCount < 1)))
                    
                }
                
            case .featureEvent(.requestRoomDelete):
                let roomID = state.roomID
                return .run { send in
                    let result = try await networkManager.requestNotDtoNetwork(
                        router: ChallengeRouter.groupChallengeDelete(groupID: roomID),
                        ifRefreshNeed: true
                    )
                    if result {
                        await send(.delegate(.removeSuccess))
                    } else {
                        await send(.featureEvent(.showAlert(.deleteFail)))
                    }
                } catch: { _, send in
                    await send(.featureEvent(.showAlert(.deleteFail)))
                }
                
            case let .featureEvent(.buttonStateUpdate(bool)):
                state.deleteButtonState = bool
                
            case .alertBinding(let value):
                state.alertComponent = value
                
            case .currentAlertState(let value):
                state.currentAlertState = value
                
            default:
                break
            }
            return .none
        }
    }
}
