//
//  WeekDay.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/18/25.
//

import Foundation

struct WeekDay: Identifiable, Entity {
    var id = UUID()
    var date: Date
    var active: Bool = true
    var isSelected: Bool = false
}

struct OneWeekDay: Entity {
    var date: Date
    var weekState: ChallengeStatusCase
}
