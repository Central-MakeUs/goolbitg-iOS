//
//  GroupChallengeCreateViewFeature.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 5/28/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data

@Reducer
public struct GroupChallengeCreateViewFeature {
    
    @ObservableState
    public struct State: Equatable {
        var onAppearTrigger = false
        var challengeName = ""
        var challengePrice = ""
        var challengePriceError: String? = nil
        var hashTagText = ""
        var passwordText = ""
        var hashTagList: [String] = []
        var currentMaxCount = 2
        var maxLeadingButtonState: Bool = false
        var maxTrailingButtonState: Bool = true
        var secretRoomState = false
        var alertViewComponent: GBAlertViewComponents? = nil
        
        var currentState = false
        var mode: FeatureMode
        var ifModifyRoomID: String
        
        public init(mode: FeatureMode = .create, ifModifyRoomID: String = "") {
            self.mode = mode
            self.ifModifyRoomID = ifModifyRoomID
        }
    }
    
    public enum FeatureMode {
        case create
        case modify
        
        var title: String {
            switch self {
            case .create:
                return "생성하기"
            case .modify:
                return "수정하기"
            }
        }
    }
    
    public enum Action {
        case viewAction(ViewAction)
        case viewCycle(ViewCycle)
        case featureAction(FeatureAction)
        
        // MARK: Binding
        case inputChallengeNameText(String)
        case inputChallengePriceText(String)
        case inputHashTagText(String)
        case inputSecretRoomState(Bool)
        case inputPasswordText(String)
        case inputSecretRoomStateAnimation(Bool)
        
        // MARK: AlertBinding
        case roomCreateStopAlertComponent(GBAlertViewComponents?)
        
        // MARK: DELEGETE
        case delegate(Delegate)
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum ViewAction {
        case tappedDismiss
        case hashTagAddTapped
        case deleteHashTagTapped(index: Int)
        case maxLeadingButtonTapped
        case maxTrailingButtonTapped
        case popUpViewAction(PopupViewAction)
        case createButtonTapped
        case modifyButtonTapped
    }
    
    public enum Delegate {
        case dismiss
        case createSuccess
        case modifySuccess
    }
    
    public enum PopupViewAction {
        case ok
        case cancel
    }
    
    public enum AlertID: String, CaseIterable {
        case roomCreateStopAlert
        case createErrorToDuplicateRoomName
        case noChallengeGroupData
    }
    
    public enum FeatureAction {
        case alertShow(alertID: AlertID)
        case requestRoomInfo(roomId: String)
        case writeInfoView(ParticipatingGroupChallengeListEntity)
        case writeMaxCount(Int)
        case requestModify
    }
    
    
    public static let currentLowCount = 2 // DEFAULT
    public static let currentMaxCount = 10
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.challengeMapper) var challengeMapper
    @Dependency(\.gbNumberForMatter) var numberForMatter
    
    public var body: some ReducerOf<Self> {
        addCore
        alertCore
        featureCore
    }
}

extension GroupChallengeCreateViewFeature {
    private var addCore: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
                
            case .viewCycle(.onAppear):
                if state.onAppearTrigger {
                    return .none
                }
                state.onAppearTrigger = true
                
                let roomID = state.ifModifyRoomID
                
                if state.mode == .modify,
                   !roomID.isEmpty {
                    return .run { send in
                        await send(.featureAction(.requestRoomInfo(roomId: roomID)))
                    }
                }
            case let .inputChallengeNameText(text):
                state.challengeName = text
                
                return checkedValid(state: &state)
                
            case let .inputChallengePriceText(text):
                let result = processingForPrice(text)
                
                state.challengePriceError = result.error
                state.challengePrice = result.price
                
                return checkedValid(state: &state)
                
            case let .inputHashTagText(text):
                state.hashTagText = text
                
            case let .inputSecretRoomState(bool):
                return .run { send in
                    await send(.inputSecretRoomStateAnimation(bool))
                }.animation()
                
            case let .inputSecretRoomStateAnimation(bool):
                state.secretRoomState = bool
                if !bool {
                    state.passwordText = ""
                }
                return checkedValid(state: &state)
                
            case let .inputPasswordText(text):
                guard let _ = Int(text),
                      text.count < 5 else  {
                    if text.isEmpty {
                        state.passwordText = ""
                    }
                    return .none
                }
                state.passwordText = text
                return checkedValid(state: &state)
                // MARK: View Action
            case .viewAction(.hashTagAddTapped): // Hash Tag Button 클릭
                if state.hashTagText.replacingOccurrences(of: " ", with: "")
                    .isEmpty {
                    state.hashTagText = ""
                } else {
                    let current = state.hashTagText
                    state.hashTagText = ""
                    state.hashTagList.append( "#"+current )
                }
                
                return checkedValid(state: &state)
                
            case let .viewAction(.deleteHashTagTapped(index)):
                state.hashTagList.remove(at: index)
                
                return checkedValid(state: &state)
                
            case .viewAction(.maxLeadingButtonTapped):
                state.currentMaxCount -= 1
                return checkLeadingTrailingButtonEnable(state: &state)
                
            case .viewAction(.maxTrailingButtonTapped):
                state.currentMaxCount += 1
                return checkLeadingTrailingButtonEnable(state: &state)
                
                // 생성하기 버튼
            case .viewAction(.createButtonTapped):
                guard let requestModel = makeRequestBody(state: state) else {
                    return .none
                }
                return .run { send in
                    let _ = try await networkManager.requestNetworkWithRefresh(
                        dto: GroupChallengeDTO.self,
                        router: ChallengeRouter.groupChallengeCreate(requestDTO: requestModel)
                    )
                    await send(.delegate(.createSuccess))
                } catch: {
                    error,
                    send in
                    guard let error = error as? RouterError else {
                        return
                    }
                    if case .serverMessage(.duplicateChallengeName) = error {
                        await send(.featureAction(.alertShow(alertID: .createErrorToDuplicateRoomName)))
                    }
                }
                // 뒤로가기
            case .viewAction(.tappedDismiss):
                return .send(.featureAction(.alertShow(alertID: .roomCreateStopAlert)))
                
            case .viewAction(.modifyButtonTapped):
                return .send(.featureAction(.requestModify))
                
            default:
                break
            }
            return .none
        }
    }

    private func checkLeadingTrailingButtonEnable(state: inout State) -> Effect<Action> {
        state.maxLeadingButtonState = state.currentMaxCount > Self.currentLowCount
        state.maxTrailingButtonState = state.currentMaxCount < Self.currentMaxCount
        return .none
    }
    
    private func checkedValid(state: inout State) -> Effect<Action> {
        var currentState = false
        
        if !state.challengeName.isEmpty,
           !state.challengePrice.isEmpty,
           state.challengePriceError == nil,
           !state.hashTagList.isEmpty {
            currentState = true
        }
        
        if state.secretRoomState {
            currentState = state.passwordText.count == 4
        }
        
        state.currentState = currentState
        return .none
    }
    
    private func makeRequestBody(state: State) -> ChallengeGroupCreateRequestDTO? {
        let intPrice = state.challengePrice.compactMap { Int(String($0)) }
            .map { String($0) }.joined()
        
        guard let reward = Int(intPrice) else {
            return nil
        }
        
        let removeSp = state.hashTagList.map { $0.replacingOccurrences(of: "#", with: "") }
        
        return ChallengeGroupCreateRequestDTO(
            title: state.challengeName,
            hashtags: removeSp,
            reward: reward,
            maxSize: state.currentMaxCount,
            isHidden: state.secretRoomState,
            password: state.passwordText.isEmpty ? nil : state.passwordText
        )
    }
}

// MARK: Alert
extension GroupChallengeCreateViewFeature {
    
    private var alertCore: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case let .featureAction(.alertShow(alertID)):
                return  showAlertHandler(state: &state, alertID: alertID)
                
            case let .roomCreateStopAlertComponent(component):
                state.alertViewComponent = component
                
            case let .viewAction(.popUpViewAction(actions)):
                guard let stateComponent = state.alertViewComponent,
                      let caseOf = AlertID.allCases.first(
                        where: {
                            $0.rawValue == stateComponent.ifNeedID
                        }) else {
                    return .none
                }
                switch caseOf {
                case .roomCreateStopAlert:
                    return groupCrateStopAlertAction(state: &state, action: actions)
                case .createErrorToDuplicateRoomName:
                    return .send(.roomCreateStopAlertComponent(nil))
                case .noChallengeGroupData:
                    return .send(.roomCreateStopAlertComponent(nil))
                }
            default:
                break
            }
            return .none
        }
    }
    
    private func showAlertHandler(state: inout State, alertID: AlertID) -> Effect<Action> {
        let component: GBAlertViewComponents
        
        switch alertID {
        case .roomCreateStopAlert:
            let text = state.mode == .create ? "생성" : "수정"
            component = GBAlertViewComponents(
                title: "작심삼일 \(text) 중단",
                message: "작심삼일 \(text)하기를\n정말 중단하시겠어요?",
                cancelTitle: "취소",
                okTitle: "중단",
                alertStyle: .warning,
                ifNeedID: alertID.rawValue
            )
        case .createErrorToDuplicateRoomName:
            component = GBAlertViewComponents(
                title: "생성 실패",
                message: "같은 이름의 챌린지가 이미 존재합니다.",
                okTitle: "확인",
                alertStyle: .warning,
                ifNeedID: alertID.rawValue
            )
        case .noChallengeGroupData:
            component = GBAlertViewComponents(
                title: "삭제 실패",
                message: "챌린지가 존재하지 않아요!",
                okTitle: "확인",
                alertStyle: .warning,
                ifNeedID: alertID.rawValue
            )
        }
        
        state.alertViewComponent = component
        return .none
    }
    
    
    /// 그룹 생성을 정말 포기할건지에 대한 팝업의 뷰 액션에 따른 결과
    /// - Parameters:
    ///   - state: State
    ///   - action: PopupAction
    /// - Returns: Effect
    private func groupCrateStopAlertAction(
        state: inout State,
        action: PopupViewAction
    ) -> Effect<Action> {
        switch action {
        case .ok:
            return .run { send in
                await send(.delegate(.dismiss))
            }
        case .cancel:
            state.alertViewComponent = nil
            return .none
        }
    }
}

extension GroupChallengeCreateViewFeature {
    
    private var featureCore: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .featureAction(.requestRoomInfo(roomId)):
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: GroupChallengeDetailDTO.self,
                        router: ChallengeRouter.groupChallengeDetail(groupID: roomId)
                    )
                    
                    let challengeMapping = challengeMapper.toMappingGroupChallenge(dto: result.group)
                    await send(.featureAction(.writeMaxCount(result.group.maxSize)))
                    await send(.featureAction(.writeInfoView(challengeMapping)))
                }
                
            case let .featureAction(.writeMaxCount(count)):
                state.currentMaxCount = count
                return checkLeadingTrailingButtonEnable(state: &state)
                
            case let .featureAction(.writeInfoView(model)):
                state.challengeName = model.title
                let intPrice = model.reward.compactMap { Int(String($0)) }
                    .map { String($0) }.joined()
                state.challengePrice = intPrice
                state.hashTagList = model.hashTags
                state.secretRoomState = model.isSecret
                state.passwordText = model.password ?? ""
                return checkedValid(state: &state)
                
            case .featureAction(.requestModify):
                guard let model = makeRequestBody(state: state),
                      !state.ifModifyRoomID.isEmpty else {
                    return .none
                }
                let id = state.ifModifyRoomID
                
                return .run { send in
                    let _ = try await networkManager.requestNetworkWithRefresh(
                        dto: GroupChallengeDTO.self,
                        router: ChallengeRouter.groupChallengeModify(groupID: id, requestDTO: model)
                    )
                    await send(.delegate(.modifySuccess))
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        return
                    }
                    if case .serverMessage(.duplicateChallengeName) = error {
                        await send(.featureAction(.alertShow(alertID: .createErrorToDuplicateRoomName)))
                    } else if case .serverMessage(.challengeNotFound) = error {
                        await send(.featureAction(.alertShow(alertID: .noChallengeGroupData)))
                    }
                }
                
            default:
                break
            }
            return .none
        }
    }
}

// MARK: Text Preprocessing
extension GroupChallengeCreateViewFeature {

    /// Price Text Processing
    /// - count: 10
    /// - Parameter price: ex) 3,000
    /// - Returns: result
    private func processingForPrice(_ price: String?) -> (price: String, error: String?) {
        guard var price else { return ("", nil) }
        if price.count > 10 {
            price.removeLast()
            return (price, nil)
        }
        
        var priceNumber = price.replacingOccurrences(of: ",", with: "")
        let numFormat = numberForMatter.changeForCommaNumber(priceNumber)
        
        if let priceNumberInt = Int(priceNumber) {
            if priceNumberInt < 1000 || priceNumberInt > 50000 {
                return (numFormat, "1000원에서 50,000원 사이로 입력해주세요.")
            } else {
                return (numFormat, nil)
            }
        } else {
            return (price, "숫자만 입력해주세요.")
        }
    }
}
