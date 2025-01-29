//
//  ChallengeTabFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChallengeTabFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        var toggleSwitchCase: [ChallengeStatusCase] = [.wait, .success]
        var selectedSwitchIndex: Int = 0
        
        var currentMonth = ""
        
        let maxCalendar = Calendar.current.date(byAdding: .year, value: -100, to: Date())!...Date()
        
        var weekSlider:[[WeekDay]] = []
        var selectedWeekDay = WeekDay(date: Date())
        var weekIndex: Int = 1
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        
        case selectedSwitchIndex(Int)
        case weekIndex(Int)
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case showChallengeAdd
        case checkPagingForWeekData
        case selectedMonthDate(Date)
        case selectedWeek(WeekDay)
    }
    
    enum FeatureEvent {
        case requestCurrentMonth(Date)
        case requestFirstSettingWeekDatas(Date)
        case requestResettingWeekDatas(Date)
        case requestNextWeekData
        case requestPrevWeekData
    }
    
    @Dependency(\.dateManager) var dateManager
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension ChallengeTabFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .viewCycle(.onAppear):
                
                return .run { send in
                    await send(.featureEvent(.requestCurrentMonth(Date())))
                    await send(.featureEvent(.requestFirstSettingWeekDatas(Date())))
                }
                
            case .viewEvent(.checkPagingForWeekData):
                let newValue = state.weekIndex
                if newValue == 2 {
                    return .send(.featureEvent(.requestNextWeekData))
                } else if newValue == 0 {
                    return .send(.featureEvent(.requestPrevWeekData))
                }
                
            case let .viewEvent(.selectedMonthDate(date)):
                return .run { send in
                    await send(.featureEvent(.requestCurrentMonth(date)))
                    await send(.featureEvent(.requestResettingWeekDatas(date)))
                }
                
            case let .viewEvent(.selectedWeek(data)):
                state.selectedWeekDay = data
                
            case let .featureEvent(.requestCurrentMonth(date)):
                let monthText = dateManager.format(format: .yyyymmddKorean, date: date)
                state.currentMonth = monthText
                
                // MARK: 최초 달력 뷰 세팅
            case let .featureEvent(.requestFirstSettingWeekDatas(date)):
                var weakSlider: [[WeekDay]] = []
                let today = Date()
                
                if state.weekSlider.isEmpty {
                    let currentWeek = dateManager.fetchWeek(date)
                    
                    if let firstDate = currentWeek.first?.date {
                        let firstStack = dateManager.createPreviousWeek(firstDate)
                        weakSlider.append(firstStack)
                    }
                    
                    weakSlider.append(currentWeek)
                    
                    if let lastDate = currentWeek.last?.date {
                        if lastDate < today {
                            let lastStack = dateManager.createNextWeek(lastDate)
                            weakSlider.append(lastStack)
                        }
                    }
                    state.weekSlider = weakSlider
                }
            case let .featureEvent(.requestResettingWeekDatas(date)):
                var weakSlider: [[WeekDay]] = []
                let currentWeek = dateManager.fetchWeek(date)
                let today = Date()
                
                if let firstDate = currentWeek.first?.date {
                    let firstStack = dateManager.createPreviousWeek(firstDate)
                    weakSlider.append(firstStack)
                }
                
                weakSlider.append(currentWeek)
                
                if let lastDate = currentWeek.last?.date {
                    if lastDate < today {
                        let lastStack = dateManager.createNextWeek(lastDate)
                        weakSlider.append(lastStack)
                    }
                }
                
                state.weekSlider = weakSlider
                
            case .featureEvent(.requestPrevWeekData):
                var weekSlider = state.weekSlider
                let index = state.weekIndex
                
                guard let firstDate = weekSlider[index].first?.date,
                      index == 0 else {
                    return .none
                }
                let prev = dateManager.createPreviousWeek(firstDate)
                
                if weekSlider.count == 3 {
                    weekSlider.removeLast()
                }
                weekSlider.insert(prev, at: 0)
                
                state.weekSlider = weekSlider
                state.weekIndex = 1
                
            case .featureEvent(.requestNextWeekData):
                var weekSlider = state.weekSlider
                let index = state.weekIndex
                let today = Date()
                
                guard let lastDate = weekSlider[index].last?.date,
                      index == 2,
                      lastDate < today else {
                    return .none
                }
                
                let behind = dateManager.createNextWeek(lastDate)
                if weekSlider.count == 3 {
                    weekSlider.removeFirst()
                }
                weekSlider.append(behind)
                
                state.weekSlider = weekSlider
                state.weekIndex = 1
                
                
            case let .selectedSwitchIndex(index):
                state.selectedSwitchIndex = index
            case let .weekIndex(index):
                state.weekIndex = index
                
            default:
                break
            }
            return .none
        }
    }
}
