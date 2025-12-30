//
//  DateManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation
import ComposableArchitecture

public final class DateManager: @unchecked Sendable {
    
    public static let shared = DateManager()
    private let calendar = Calendar.current
    private lazy var weekCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.firstWeekday = 2
        return calendar
    }()
    
    private let dateFormatter = DateFormatter()
    
    public enum FormatType: String {
        case simpleE = "E"
        case dayD = "d"
        case dayDD = "dd"
        case yearMonth = "yyyy년 MM월"
        case infoBirthDay = "yyyy-MM-dd"
        case timeHHmmss = "HH:mm:ss"
        case dicToDateForYYYYMMDD = "yyyy.MM.dd"
        case yyyymmddKorean = "yyyy년 MM월 dd일"
        case serverDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        public var format: String {
            return self.rawValue
        }
    }
    
    private init() {}
}

extension DateManager {
    
    public func dateFormatToBirthDay(_ date: Date) -> String {
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let result = dateFormatter.string(from: date)
        return result
    }
    
    public func fetchWeekDate(_ date: Date = Date()) -> [Date] {
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
    
    public func findNextWeek(_ firstDate: Date) -> Date? {
        let startOfWeek = weekCalendar.startOfDay(for: firstDate)
        return calendar.date(byAdding: .day, value: 1, to: startOfWeek)
    }

    public func findPreviousWeek(_ firstDate: Date) -> Date? {
        let startOfWeek = weekCalendar.startOfDay(for: firstDate)
        return calendar.date(byAdding: .day, value: -1, to: startOfWeek)
    }
    
    public func updateHour(_ value: Int) -> Date {
        return calendar.date(byAdding: .hour,value: value , to: Date()) ?? Date()
    }
    
    public func format(format: FormatType, date: Date) -> String {
        dateFormatter.dateFormat = format.format
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    
    public func isToday(_ date: Date) -> Bool {
        return weekCalendar.isDateInToday(date)
    }
    
    public func isBeforeToday(_ date: Date) -> Bool {
        let today = Date()
        return weekCalendar.compare(date, to: today, toGranularity: .day) == .orderedAscending
    }
    
    public func isSameDay(date: Date, date2: Date) -> Bool {
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

extension DateManager {
    
    public func diffDate(_ date: String, format: FormatType) -> String {
        let formatString = format.format
        dateFormatter.dateFormat = formatString
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let givenDate = dateFormatter.date(from: date) else {
            return "-"
        }
        
        let now = Date()
        let components = calendar.dateComponents(
            [.year, .month, .weekOfYear, .day, .hour, .minute, .second],
            from: givenDate,
            to: now
        )
        
        if let years = components.year, years > 0 {
            return "\(years)년 전"
        }
        if let months = components.month, months > 0 {
            return "\(months)개월 전"
        }
        if let weeks = components.weekOfYear, weeks > 0 {
            return "\(weeks)주 전"
        }
        if let days = components.day, days > 0 {
            return "\(days)일 전"
        }
        if let hours = components.hour, hours > 0 {
            return "\(hours)시간 전"
        }
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes)분 전"
        }
        if let seconds = components.second, seconds > 10 {
            return "\(seconds)초 전"
        }
        
        return "방금 전"
    }
}

extension DateManager: DependencyKey {
    public static let liveValue: DateManager = DateManager.shared
}
extension DependencyValues {
    public var dateManager: DateManager {
        get { self[DateManager.self] }
        set { self[DateManager.self] = newValue }
    }
}

