//
//  BuyOrNotChartDataEntity.swift
//  Data
//
//  Created by Jae hyung Kim on 10/13/25.
//

import Foundation
import Domain

public protocol BuyOrNotChartDataEntityProtocol: Entity {
    var goodOrBad: Bool { get }
    var rate: Double { get }
}

public struct BuyOrNotChartDataEntity: BuyOrNotChartDataEntityProtocol {
    /// Good = true
    public let goodOrBad: Bool
    public let rate: Double
    
    public init(goodOrBad: Bool, rate: Double) {
        self.goodOrBad = goodOrBad
        self.rate = rate
    }
}
