//
//  ChallengeAddViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChallengeAddViewFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        var currentFamousList: [ChallengeEntity]? = nil
        var currentAnotherList: [ChallengeEntity]? = nil
        var dismissButtonHidden: Bool
        var selectedEntity: ChallengeEntity? = nil
        var alertComponents: GBAlertViewComponents? = nil
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        
        enum Delegate {
            case dismissTapped
            case moveToHome
        }
        case selectedEntityBinding(ChallengeEntity?)
        case alertComponents(GBAlertViewComponents?)
    }
    
    var body: some ReducerOf<Self> {
        core
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case dismissButtonTapped
        case selectedChallenge(ChallengeEntity)
        case tryButtonTapped(item: ChallengeEntity)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.challengeMapper) var challengeMapper
    
    enum FeatureEvent {
        case requestAPIForChallengeList
        case setFamousList([ChallengeEntity])
        case setAnotherList([ChallengeEntity])
        case errorController(errorEntity: APIErrorEntity)
    }
}

extension ChallengeAddViewFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { send in
                    try? await Task.sleep(for: .seconds(1))
                    await send(.featureEvent(.requestAPIForChallengeList))
                }
                
            case .featureEvent(.requestAPIForChallengeList):
                // MARK: 유형별 다시 꽃아놓기
                let userHabitType: Int? = nil // UserDefaultsManager.userHabitType
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(dto: ChallengeListDTO.self, router: ChallengeRouter.challengeList(spendingTypeID: userHabitType))
                    
                    let mapping = await challengeMapper.toEntity(dto: result)
                    
                    await send(.featureEvent(.setFamousList(mapping)))
                    await send(.featureEvent(.setAnotherList(mapping)))
                    
                } catch: { error, send in
                    Logger.error(error)
                }
                
            case let .featureEvent(.setFamousList(models)):
                let result = Array(models.prefix(3))
                
                state.currentFamousList = result
                
            case let .featureEvent(.setAnotherList(models)):
                let result = Array(models.dropFirst(3))

                state.currentAnotherList = result
                
            case .viewEvent(.dismissButtonTapped):
                return .send(.delegate(.dismissTapped))
                
            case let .viewEvent(.selectedChallenge(data)):
                // 팝업 띄우기
                state.selectedEntity = data
                
            case let .selectedEntityBinding(value):
                state.selectedEntity = value
                
            case let .viewEvent(.tryButtonTapped(item)):
                // 팝업 내리기
                state.selectedEntity = nil
                return .run { send in
                    try await networkManager.requestNotDtoNetwork(
                        router: ChallengeRouter.challengeEnroll(challengeID: item.id),
                        ifRefreshNeed: true
                    )
                    await send(.delegate(.moveToHome))
                } catch: { error, send in
                    guard let error = error as? RouterError,
                          case let .serverMessage(errorEntity) = error else {
                        Logger.error(error)
                        return
                    }
                    await send(.featureEvent(.errorController(errorEntity: errorEntity)))
                }
                
            case let .featureEvent(.errorController(errorEntity)):
                switch errorEntity {
                case .challengeNotFound:
                    state.alertComponents = GBAlertViewComponents(
                        title: "오류",
                        message: "찾을 수 없는 챌린지 입니다.",
                        okTitle: "확인",
                        alertStyle: .warning
                    )
                case .alreadyParticipatingChallenge:
                    state.alertComponents = GBAlertViewComponents(
                        title: "오류",
                        message: "이미 참여중인 챌린지 입니다.",
                        okTitle: "확인",
                        alertStyle: .warning
                    )
                default:
                    break
                }
            case let .alertComponents(model):
                state.alertComponents = model
            default:
                break
            }
            return .none
        }
    }
}
