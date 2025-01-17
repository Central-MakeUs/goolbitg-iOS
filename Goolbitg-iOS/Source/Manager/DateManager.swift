//
//  DateManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation
import ComposableArchitecture

final class DateManager: Sendable {
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
}

extension DateManager {
    
    func dateFormatToBirthDay(_ date: Date) -> String {
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let result = dateFormatter.string(from: date)
        return result
    }
    
}

extension DateManager: DependencyKey {
    static let liveValue: DateManager = DateManager()
}
extension DependencyValues {
    var dateManager: DateManager {
        get { self[DateManager.self] }
        set { self[DateManager.self] = newValue }
    }
}

