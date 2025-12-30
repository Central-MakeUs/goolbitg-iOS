//
//  WeekDay.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/18/25.
//

import Foundation
import Domain
import Utils

public struct WeekDay: Identifiable, Entity {
    public var id = UUID()
    public var date: Date
    public var active: Bool = true
    public var isSelected: Bool = false
    public var percent: Double = 0
    
    public init(
        id: UUID = UUID(),
        date: Date,
        active: Bool = true,
        isSelected: Bool = false,
        percent: Double = 0
    ) {
        self.id = id
        self.date = date
        self.active = active
        self.isSelected = isSelected
        self.percent = percent
    }
}

public struct OneWeekDay: Entity {
    public var date: Date
    public var weekState: Bool
    
    public init(date: Date, weekState: Bool) {
        self.date = date
        self.weekState = weekState
    }
}


extension DateManager {
    public func fetchMonth(_ date: Date = Date()) -> [WeekDay] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.firstWeekday = 2 // 월요일 기준
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }
        
        var month: [WeekDay] = []
        let today = calendar.startOfDay(for: date)
        
        for day in range {
            if let currentDate = calendar.date(byAdding: .day, value: day, to: startOfMonth) {
                // 오늘 이후는 active = false, 오늘 이전은 active = true
                let isFutureDate = currentDate > today
                month.append(WeekDay(date: currentDate, active: !isFutureDate))
            }
        }
        return month
    }
    
    public func fetchWeek(_ date: Date = Date()) -> [WeekDay] {
        let dates = fetchWeekDate(date)
        let weeks = dates.map { WeekDay(date: $0, active: true) }
        return weeks
    }
    
    public func createNextWeek(_ firstDate: Date) -> [WeekDay] {
        guard let find = findNextWeek(firstDate) else {
            return []
        }
        return fetchWeek(find)
    }
    
    public func createPreviousWeek(_ firstDate: Date) -> [WeekDay] {
        guard let find = findPreviousWeek(firstDate) else {
            return []
        }
        print("---- FIND PREV \(find)")
        print("---- FIND PREV \(find)")
        
        return fetchWeek(find)
    }
}
