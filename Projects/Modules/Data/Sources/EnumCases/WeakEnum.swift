//
//  WeakEnum.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/13/25.
//

import Foundation

public enum WeakEnum: Equatable, CaseIterable, Hashable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    public var title: String {
        switch self {
        case .monday:
            return "월요일"
        case .tuesday:
            return "화요일"
        case .wednesday:
            return "수요일"
        case .thursday:
            return "목요일"
        case .friday:
            return "금요일"
        case .saturday:
            return "토요일"
        case .sunday:
            return "일요일"
        }
    }
    
    public var format: String {
        switch self {
        case .monday:
            return "MONDAY"
        case .tuesday:
            return "TUESDAY"
        case .wednesday:
            return "WEDNESDAY"
        case .thursday:
            return "THURSDAY"
        case .friday:
            return "FRIDAY"
        case .saturday:
            return "SATURDAY"
        case .sunday:
            return "SUNDAY"
        }
    }
}
