//
//  UserHabitReqeustModel.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/25/25.
//

import Foundation

public struct UserHabitRequestModel: Encodable {
    public let avgIncomePerMonth: Int
    public let avgSavingPerMonth: Int
    
    public init(avgIncomePerMonth: Int, avgSavingPerMonth: Int) {
        self.avgIncomePerMonth = avgIncomePerMonth
        self.avgSavingPerMonth = avgSavingPerMonth
    }
}
