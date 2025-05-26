//
//  ChallengeTabFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data
import FeatureCommon

@Reducer
public struct ChallengeTabFeature: GBReducer {
    public init () {}
    
    @ObservableState
    public struct State: Equatable {
        public init () {}
        
        var toggleSwitchCase: [ChallengeStatusCase] = [.wait, .success]
        var selectedSwitchIndex: Int = 0
        
        var onAppearTrigger = false
        
        let maxCalendar = Calendar.current.date(byAdding: .year, value: -100, to: Date())!...Date()
        
        var weekSlider:[[WeekDay]] = []
        var selectedWeekDay = WeekDay(date: Date())
        var weekIndex: Int = 1
        
        var datePickerMonth = Date()
        
        var todayDate = Date()
        var isToday: Bool = true
        
        var listLoad = false
        var pagingObj = PagingObj()
        var challengeList: [ChallengeEntity] = []
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        case parentEvent(ParentEvent)
        
        case selectedSwitchIndex(Int)
        case weekIndex(Int)
        
        public enum Delegate {
            case moveToChallengeAdd
            case moveToDetail(itemID: String)
            case hiddenTabBar
            case showTabBar
        }
        
        case datePickerMonth(Date)
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum ViewEvent {
        case showChallengeAdd
        case checkPagingForWeekData
        case selectedMonthDate(Date)
        case selectedWeek(WeekDay)
        case selectedDetail(item: ChallengeEntity)
        case currentIndex(Int)
    }
    
    public enum FeatureEvent {
//        case requestCurrentMonth(Date)
        case requestFirstSettingWeekDatas(Date)
        case requestResettingWeekDatas(Date)
        case requestNextWeekData
        case requestPrevWeekData
        
        case settingDate(data: WeekDay)
        case settingRequestList(Date)
        case reSettingRequestList
        
        case firstResultWeekData([[WeekDay]])
        case resultPrevWeekData([WeekDay])
        case resultNextWeekData([WeekDay])
        
        case requestChallengeList(obj: PagingObj)
        case resultToChallengeList(dats: [ChallengeEntity])
    }
    
    public enum ParentEvent {
        case reloadData
    }
    
    enum CancelID: Hashable {
        case switchToggle
        case checkWeekDate
    }
    
    @Dependency(\.dateManager) var dateManager
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.challengeMapper) var challengeMapper
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension ChallengeTabFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .viewCycle(.onAppear):
                if !state.onAppearTrigger {
                    state.onAppearTrigger = true
                    let page = state.pagingObj
                    state.listLoad = true
                    return .run { send in
                        await send(.featureEvent(.requestFirstSettingWeekDatas(Date())))
                        await send(.featureEvent(.requestChallengeList(obj: page)))
                    }
                } else {
                    state.todayDate = Date()
                }
                
            case .viewEvent(.checkPagingForWeekData):
                let newValue = state.weekIndex
                return .run { send in
                    if newValue == 2 {
                        await send(.featureEvent(.requestNextWeekData))
                    } else if newValue == 0 {
                        await send(.featureEvent(.requestPrevWeekData))
                    }
                }
                .throttle(id: CancelID.checkWeekDate, for: 0.4, scheduler: RunLoop.main.eraseToAnyScheduler(), latest: false)
                
                
            case let .viewEvent(.selectedMonthDate(date)):
                return .run { send in
                    await send(.featureEvent(.settingDate(data: WeekDay(date: date))))
                    await send(.featureEvent(.requestResettingWeekDatas(date)))
                    await send(.featureEvent(.settingRequestList(date)))
                }

                
            case let .viewEvent(.selectedWeek(data)):
                return .run { send in
                    await send(.featureEvent(.settingDate(data: data)))
                    
                }
                .animation(.bouncy(duration: 0.4))
                
            case let .featureEvent(.settingRequestList(date)):
                var paging = PagingObj()
                paging.date = date
                state.pagingObj = paging
                
                state.listLoad = true
                return .send(.featureEvent(.requestChallengeList(obj: state.pagingObj)))
                
            case .featureEvent(.reSettingRequestList):
                let paging = PagingObj()
                state.pagingObj = paging
                
                state.listLoad = true
                return .send(.featureEvent(.requestChallengeList(obj: state.pagingObj)))
                
            case .viewEvent(.showChallengeAdd):
                return .send(.delegate(.moveToChallengeAdd))
                
            case let .viewEvent(.selectedDetail(item)):
                return .send(.delegate(.moveToDetail(itemID: item.id)))
                
                // MARK: 최초 달력 뷰 세팅
            case let .featureEvent(.requestFirstSettingWeekDatas(date)):
                
                if !state.weekSlider.isEmpty { return .none }
                
                return .run { send in
                    var weekSlider: [[WeekDay]] = []
                    
                    let currentWeekEntity = dateManager.fetchWeek(date)
                    let currentWeek = try await networkManager.requestNetworkWithRefresh(
                        dto: UserWeeklyStatusDTO.self,
                        router: UserRouter.weeklyStatus(dateString: nil)
                    )
                    let currentWeekResult = await challengeMapper.toMappingWeek(weekDays: currentWeekEntity, currentWeek: currentWeek)
                    
                    
                    if let firstDate = currentWeekEntity.first?.date {
                        let previousWeekEntity = dateManager.createPreviousWeek(firstDate)
                        
                        let dateString = dateManager.format(
                            format: .infoBirthDay,
                            date: previousWeekEntity.first?.date ?? Date()
                        )
                        
                        let previousWeek = try await networkManager.requestNetworkWithRefresh(
                            dto: UserWeeklyStatusDTO.self,
                            router: UserRouter.weeklyStatus(dateString: dateString)
                        )
                        
                        let prevResult = await challengeMapper.toMappingWeek(weekDays: previousWeekEntity, currentWeek: previousWeek)
                        
                        weekSlider.append(prevResult)
                    }
                    
                    weekSlider.append(currentWeekResult)
                    
                    await send(.featureEvent(.firstResultWeekData(weekSlider)))
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        return
                    }
                    Logger.error(error)
                }
                
            case let .featureEvent(.firstResultWeekData(datas)):
                state.weekSlider = datas
                state.weekIndex = 1
                
            case let .featureEvent(.requestResettingWeekDatas(date)):

                return .run { send in
                    var weekSlider: [[WeekDay]] = []
                    
                    let currentWeekEntity = dateManager.fetchWeek(date)
                    let getDateString = dateManager.format(
                        format: .infoBirthDay,
                        date: date
                    )
                    
                    let currentWeek = try await networkManager.requestNetworkWithRefresh(
                        dto: UserWeeklyStatusDTO.self,
                        router: UserRouter.weeklyStatus(dateString: getDateString)
                    )
                    let currentWeekResult = await challengeMapper.toMappingWeek(weekDays: currentWeekEntity, currentWeek: currentWeek)
                    
                    
                    if let firstDate = currentWeekEntity.first?.date {
                        let previousWeekEntity = dateManager.createPreviousWeek(firstDate)
                        
                        let dateString = dateManager.format(
                            format: .infoBirthDay,
                            date: previousWeekEntity.first?.date ?? Date()
                        )
                        
                        let previousWeek = try await networkManager.requestNetworkWithRefresh(
                            dto: UserWeeklyStatusDTO.self,
                            router: UserRouter.weeklyStatus(dateString: dateString)
                        )
                        
                        let prevResult = await challengeMapper.toMappingWeek(weekDays: previousWeekEntity, currentWeek: previousWeek)
                        
                        weekSlider.append(prevResult)
                    }
                    
                    weekSlider.append(currentWeekResult)
                    
                    if let lastDate = currentWeekEntity.last?.date {
                        if lastDate < Date() {
                            let lastStack = dateManager.createNextWeek(lastDate)
                            
                            let dateString = dateManager.format(
                                format: .infoBirthDay,
                                date: lastStack.first?.date ?? Date()
                            )
                            
                            let lastWeek = try await networkManager.requestNetworkWithRefresh(
                                dto: UserWeeklyStatusDTO.self,
                                router: UserRouter.weeklyStatus(dateString: dateString)
                            )
                            
                            let lastResult = await challengeMapper.toMappingWeek(weekDays: lastStack, currentWeek: lastWeek)
                            
                            weekSlider.append(lastResult)
                        }
                    }
                    
                    await send(.featureEvent(.firstResultWeekData(weekSlider)))
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        return
                    }
                    Logger.error(error)
                }
                
            case .featureEvent(.requestPrevWeekData):
                let weekSlider = state.weekSlider
                let index = state.weekIndex
                
                guard let firstDate = weekSlider[index].first?.date,
                      index == 0 else {
                    return .none
                }
                
                return .run { send in
                    let prev = dateManager.createPreviousWeek(firstDate)
                    
                    let dateString = dateManager.format(
                        format: .infoBirthDay,
                        date: prev.first?.date ?? Date()
                    )
                    
                    let previousWeek = try await networkManager.requestNetworkWithRefresh(
                        dto: UserWeeklyStatusDTO.self,
                        router: UserRouter.weeklyStatus(dateString: dateString)
                    )
                    
                    let mapping = await challengeMapper.toMappingWeek(weekDays: prev, currentWeek: previousWeek)
                    
                    await send(.featureEvent(.resultPrevWeekData(mapping)))
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        return
                    }
                    Logger.error(error)
                }
                
            case let .featureEvent(.resultPrevWeekData(prev)):
                var weekSlider = state.weekSlider
                
                if weekSlider.count == 3 {
                    weekSlider.removeLast()
                }
                weekSlider.insert(prev, at: 0)
                
                state.weekSlider = weekSlider
                state.weekIndex = 1
                
            case .featureEvent(.requestNextWeekData):
                let weekSlider = state.weekSlider
                let index = state.weekIndex
                let today = Date()
                
                guard let lastDate = weekSlider[index].last?.date,
                      index == 2,
                      lastDate < today else {
                    return .none
                }
                
                return .run { send in
                    let nextWeek = dateManager.createNextWeek(lastDate)
                    
                    let dateString = dateManager.format(
                        format: .infoBirthDay,
                        date: nextWeek.first?.date ?? Date()
                    )
                    
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: UserWeeklyStatusDTO.self,
                        router: UserRouter.weeklyStatus(dateString: dateString)
                    )
                    
                    let mapping = await challengeMapper.toMappingWeek(weekDays: nextWeek, currentWeek: result)
                    
                    await send(.featureEvent(.resultNextWeekData(mapping)))
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        return
                    }
                    Logger.error(error)
                }
                
            case let .featureEvent(.resultNextWeekData(next)):
                var weekSlider = state.weekSlider
                
                if weekSlider.count == 3 {
                    weekSlider.removeFirst()
                }
                weekSlider.append(next)
                
                state.weekSlider = weekSlider
                state.weekIndex = 1
                
            case let .featureEvent(.requestChallengeList(obj)):
                let selectedSwitchIndex = state.selectedSwitchIndex
                let toggleCase = state.toggleSwitchCase
                let isToday = state.isToday
                
                return .run { send in
                    let dateFormat = dateManager.format(format: .infoBirthDay, date: obj.date)
                    let status = toggleCase[selectedSwitchIndex]
                    
                    let results: ChallengeListDTO<ChallengeRecordDTO>
                    if isToday {
                        results = try await networkManager.requestNetworkWithRefresh(
                            dto: ChallengeListDTO<ChallengeRecordDTO>.self,
                            router: ChallengeRouter.challengeRecords(
                                page: obj.pageNum,
                                size: obj.size,
                                date: dateFormat,
                                state: status.requestMode
                            )
                        )
                    } else {
                        results = try await networkManager.requestNetworkWithRefresh(
                            dto: ChallengeListDTO<ChallengeRecordDTO>.self,
                            router: ChallengeRouter.challengeRecords(
                                page: obj.pageNum,
                                size: obj.size,
                                date: dateFormat,
                                state: nil
                            )
                        )
                    }
                    
                    let mapping = await challengeMapper.toEntity(dtos: results.items)
                    await send(.featureEvent(.resultToChallengeList(dats: mapping)))
                } catch: { error, send in
                    guard let error = error as? RouterError,
                          case let .serverMessage(errorModel) = error else {
                        Logger.warning(error)
                        return
                    }
                    Logger.info(errorModel)
                }
                
            case let .featureEvent(.settingDate(data)):
                state.selectedWeekDay = data
                state.datePickerMonth = data.date
                
                state.isToday = dateManager.isSameDay(date: Date(), date2: data.date)
                
                return .send(.featureEvent(.settingRequestList(data.date)))
                
            case let .featureEvent(.resultToChallengeList(datas)):
                state.challengeList = datas
                state.listLoad = false
                
                // MARK: Parent
            case .parentEvent(.reloadData):
                let page = state.pagingObj
                state.datePickerMonth = Date()
                state.selectedWeekDay = WeekDay(date: Date())
                
                state.listLoad = true
                return .run { send in
                    await send(.featureEvent(.requestResettingWeekDatas(Date())))
                    await send(.featureEvent(.requestChallengeList(obj: page)))
                }
                
            case let .selectedSwitchIndex(index):
                state.selectedSwitchIndex = index
                state.challengeList = []
                let obj = state.pagingObj
                
                state.listLoad = true
                return .run { send in
                    await send(.featureEvent(.requestChallengeList(obj: obj)))
                }
                .debounce(id: CancelID.switchToggle, for: 0.5, scheduler: DispatchQueue.main.eraseToAnyScheduler())
                
            case let .weekIndex(index):
                state.weekIndex = index
                
            case let .datePickerMonth(date):
                state.datePickerMonth = date
            default:
                break
            }
            return .none
        }
    }
}
