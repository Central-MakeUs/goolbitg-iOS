//
//  DateManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation
import ComposableArchitecture

final class DateManager: @unchecked Sendable {
    
    static let shared = DateManager()
    private let calendar = Calendar.current
    private lazy var weekCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.firstWeekday = 2
        return calendar
    }()
    
    private let dateFormatter = DateFormatter()
    
    enum FormatType: String {
        case simpleE = "E"
        case dayD = "d"
        case dayDD = "dd"
        case yearMonth = "yyyy년 MM월"
        case infoBirthDay = "yyyy-MM-dd"
        case timeHHmmss = "HH:mm:ss"
        case dicToDateForYYYYMMDD = "yyyy.MM.dd"
        case yyyymmddKorean = "yyyy년 MM월 dd일"
        
        var format: String {
            return self.rawValue
        }
    }
    
    private init() {}
}

extension DateManager {
    
    func dateFormatToBirthDay(_ date: Date) -> String {
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let result = dateFormatter.string(from: date)
        return result
    }
    
    func fetchMonth(_ date: Date = Date()) -> [WeekDay] {
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
    
    func fetchWeek(_ date: Date = Date()) -> [WeekDay] {
        let startDate = weekCalendar.startOfDay(for: date)
        
        var weeks: [WeekDay] = []
        
        let weekDate = weekCalendar.dateInterval(of: .weekOfMonth, for: startDate)
        guard let startOfWeek = weekDate?.start else { return [] }
        
        for i in 0..<7 {
            guard let currentDate = weekCalendar.date(byAdding: .day, value: i, to: startOfWeek) else { continue }
            weeks.append(WeekDay(date: currentDate, active: true))
        }
        return weeks
    }
    
    func fetchWeekDate(_ date: Date = Date()) -> [Date] {
        let startDate = weekCalendar.startOfDay(for: date)
        
        var weeks: [Date] = []
        
        let weekDate = weekCalendar.dateInterval(of: .weekOfMonth, for: startDate)
        guard let startOfWeek = weekDate?.start else { return [] }
        
        for i in 0..<7 {
            guard let currentDate = weekCalendar.date(byAdding: .day, value: i, to: startOfWeek) else { continue }
            weeks.append(currentDate)
        }
        return weeks
    }
    
    func createNextWeek(_ lastDate: Date) -> [WeekDay] {
        let start = weekCalendar.startOfDay(for: lastDate)
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: start) else {
            return []
        }
        return fetchWeek(nextDate)
    }
    
    func createPreviousWeek(_ lastDate: Date) -> [WeekDay] {
        let start = weekCalendar.startOfDay(for: lastDate)
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: start) else {
            return []
        }
        return fetchWeek(previousDate)
    }
    
    func updateHour(_ value: Int) -> Date {
        return calendar.date(byAdding: .hour,value: value , to: Date()) ?? Date()
    }
    
    func format(format: FormatType, date: Date) -> String {
        dateFormatter.dateFormat = format.format
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    
    func isToday(_ date: Date) -> Bool {
        return weekCalendar.isDateInToday(date)
    }
    
    func isBeforeToday(_ date: Date) -> Bool {
        let today = Date()
        return weekCalendar.compare(date, to: today, toGranularity: .day) == .orderedAscending
    }
    
    func isSameDay(date: Date, date2: Date) -> Bool {
        return calendar.isDate(date, inSameDayAs: date2)
    }
    
//    func isInCurrentWeek(_ date: Date) -> Bool {
//        guard let startOfWeek = weekCalendar.date(from: weekCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))
//        else {
//            return false
//        }
//        
//        guard let endOfWeek = weekCalendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
//            return false
//        }
//        
//        return date >= startOfWeek && date <= endOfWeek
//    }
}

extension DateManager: DependencyKey {
    static let liveValue: DateManager = DateManager.shared
}
extension DependencyValues {
    var dateManager: DateManager {
        get { self[DateManager.self] }
        set { self[DateManager.self] = newValue }
    }
}

