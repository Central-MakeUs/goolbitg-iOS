//
//  AuthRequestFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AuthRequestFeature {
    
    enum BirthDayShowTextState {
        case show
        case placeholder
    }
    
    @ObservableState
    struct State: Equatable {
        var nickName: String = ""
        var birthDayText = ""
        
        let maxCalendar: ClosedRange<Date> = {
            let fourteenYearsAgo = Calendar.current.date(byAdding: .year, value: -14, to: Date())!
            let hundredYearsAgo = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
            let validDateRange = hundredYearsAgo...fourteenYearsAgo
            return validDateRange
        }()
        
        var birthDayShowTextState: BirthDayShowTextState = .placeholder
        var birthDayDate = Date()
        var currentGender: GenderType? = nil
        
        var isDuplicateButtonState = false
        var isActionButtonState = false
        var nickNameResult: NickNameValidateEnum = .none
        var dateState: Bool = false
        var showAgreeBottomSheet = false
        var agreeList: Set<AgreeListCase> = []
        var allAgreeButtonState: Bool = false
        var agreeStartButtonState: Bool = false
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        
        // TextBinding
        case nickNameText(String)

        case nickNameTextChecker(String)
        
        case selectedDate(Date)
        // nickNameCheckedResult
        case nickNameCheckedResult(Bool)
        case agreeBottomSheet(Bool)
        case agreeStartButtonState(Bool)
        case delegate(Delegate)
        
        enum Delegate {
            case successNextView
        }
    }
    
    enum ViewEvent: Equatable {
        case maleTaped
        case femaleTapped
        case duplicatedButtonTapped
        case nickNameTextFieldEventEnd
        case agreeStartButtonTapped
        case agreeListButtonTapped(AgreeListCase)
        case agreeListRightButtonTapped(AgreeListCase)
        case allAgreeButtonTapped
        case startButtonTapped
    }
    
    @Dependency(\.dateManager) var dateFormatter
    @Dependency(\.textValidManager) var textValidManager
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.moveURLManager) var moveURLManager
    
    static let test = "test"
    
    var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
                
            case .nickNameText(let text):
                /// Note - 텍스트 이슈 해결
                return .send(.nickNameTextChecker(text))
                
            case .nickNameTextChecker(let text):
                let removeNext = text.removeNextLine
                let removeSpacing = removeNext.removeSpacing
                
                print(removeSpacing, text)
                if text != state.nickName {
                    state.nickName = removeSpacing
                }
                
                if !text.isEmpty {
                    let result = nickNameTextCheck(nickName: removeSpacing)
                    state.nickNameResult = result
                    state.isDuplicateButtonState = ((result == .none) && !removeSpacing.isEmpty)
                }
                
                checkedButtonState(state: &state)
                
            case .selectedDate(let date):
                state.birthDayDate = date
                let dateString = mappingToStringDate(date: date)
                
                state.birthDayText = dateString
                state.birthDayShowTextState = .show
                
                state.dateState = true
                checkedButtonState(state: &state)
                
            case .viewEvent(.maleTaped):
                state.currentGender = .male
                checkedButtonState(state: &state)
                
            case .viewEvent(.femaleTapped):
                state.currentGender = .female
                checkedButtonState(state: &state)
                
                /// 통신해야함 중복 검사
            case .viewEvent(.duplicatedButtonTapped):
                let nickName = state.nickName
                
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: NickNameCheckDTO.self,
                        router: UserRouter.nickNameCheck(
                            reqeustModel: UserNickNameCheckReqeustModel(
                                nickname: nickName
                            )
                        )
                    )
                    await send(.nickNameCheckedResult(result.duplicated))
                }
                
            case .nickNameCheckedResult(let duplicated):
                state.nickNameResult = duplicated ? .alreadyUse : .active
                checkedButtonState(state: &state)
                
            case .viewEvent(.nickNameTextFieldEventEnd):
                state.nickName = state.nickName.replacingOccurrences(of: ".", with: "")
             
            case .viewEvent(.agreeStartButtonTapped):
                state.showAgreeBottomSheet = true
                
            case let .agreeBottomSheet(bool):
                state.showAgreeBottomSheet = bool
                
            case let .viewEvent(.agreeListButtonTapped(caseOf)):
                if state.agreeList.contains(caseOf){
                    state.agreeList.remove(caseOf)
                } else {
                    state.agreeList.insert(caseOf)
                }
                
                checkedAgreeButtonState(state: &state)
                
            case .viewEvent(.allAgreeButtonTapped):
                AgreeListCase.allCases.forEach {
                    state.agreeList.insert($0)
                }
                
                checkedAgreeButtonState(state: &state)
                
            case let .viewEvent(.agreeListRightButtonTapped(caseOf)):
                
                switch caseOf {
                case .fourTeen:
                    break
                case .serviceAgree:
                    moveURLManager.moveURL(caseOf: .service)
                case .privateAgree:
                    moveURLManager.moveURL(caseOf: .privacy)
                case .adAgree:
                    moveURLManager.moveURL(caseOf: .inquiry)
                }
                
            case let .agreeStartButtonState(bool):
                state.agreeStartButtonState = bool
                
            case .viewEvent(.startButtonTapped):
                return registerRequest(state: &state)
                
            default:
                break
            }
            return .none
        }
    }
}

extension AuthRequestFeature {
    
    private func nickNameTextCheck(nickName: String) -> NickNameValidateEnum {
        
        if !((nickName.count >= 2) && (nickName.count <= 6)) {
            return .limitOverOrUnder
        }
        
        if !textValidManager.textValidCheck(validMode: .nickNameKoreanAndEnglish, text: nickName) {
            return .denied
        }
        
        return .none
    }
    
    private func mappingToStringDate(date: Date) -> String {
        return dateFormatter.dateFormatToBirthDay(date)
    }
    
    private func checkedButtonState(state: inout State) {
        let nickNameState = state.nickNameResult == .active
        let birthDayState = state.dateState
        let genderState = state.currentGender != nil
        
        print(nickNameState, birthDayState, genderState)
        
        state.isActionButtonState = nickNameState && birthDayState && genderState
    }
    
    private func checkedAgreeButtonState(state: inout State) {
        let allButtonState = state.agreeList == Set(AgreeListCase.allCases)
        state.allAgreeButtonState = allButtonState
        
        let requiredCases: Set<AgreeListCase> = [.fourTeen, .serviceAgree, .privateAgree]
        state.agreeStartButtonState = requiredCases.isSubset(of: state.agreeList)
    }
    
    /// 약관동의 + 유저 등록
    private func registerRequest(state: inout State) -> Effect<Action> {
        guard let gender = state.currentGender else {
            return .none
        }
        
        let currentAgreeList = state.agreeList
        let allCases = AgreeListCase.allCases
        let bools = allCases.map { currentAgreeList.contains($0) }
        
        let requestModel = UserAgreeMentRequestModel(
            agreement1: bools[0],
            agreement2: bools[1],
            agreement3: bools[2],
            agreement4: bools[3]
        )
        
        let nickName = state.nickName
        
        let userRequestModel = UserInfoRegistReqeustModel(
            nickname: nickName,
            birthday: dateFormatter.format(format: .infoBirthDay, date: state.birthDayDate),
            gender: gender.formattedString
        )
        
        return .run { send in
            /// 약관동의
            try await networkManager.requestNotDtoNetwork(
                router: UserRouter.agreement(requestModel: requestModel),
                ifRefreshNeed: true
            )
            /// 유저 등록
            try await networkManager.requestNotDtoNetwork(
                router: UserRouter.userInfoRegist(reqeustModel: userRequestModel),
                ifRefreshNeed: true
            )
            UserDefaultsManager.userNickname = nickName
            await send(.agreeBottomSheet(false))
            await send(.delegate(.successNextView))
        } catch: { error, send in
            guard let error = error as? RouterError else {
                return
            }
            await send(.agreeBottomSheet(false))
            Logger.error(error)
        }
    }
}
