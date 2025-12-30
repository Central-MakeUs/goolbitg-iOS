//
//  CategoryCompareEntity.swift
//  Data
//
//  Created by Jae hyung Kim on 10/9/25.
//

import Foundation
import Domain

public struct CategoryCompareEntity: Entity {
    public let topCategory: String
    public let allCategories: [CategoryInfo]
    
    public init(topCategory: String, allCategories: [CategoryInfo]) {
        self.topCategory = topCategory
        self.allCategories = allCategories
    }
}

// MARK: - 차트 아이템 프로토콜/모델
public protocol GBRadarChartItemProtocol {
    /// 항목 이름(라벨)
    var name: String { get }
    /// 현재 값
    var currentValue: Double { get }
    /// 최대 값
    var maxValue: Double { get }
}

public struct CategoryInfo: Entity, GBRadarChartItemProtocol {
    public let name: String
    public let currentValue: Double
    public let maxValue: Double
    
    public init(name: String, currentValue: Double, maxValue: Double) {
        self.name = name
        self.currentValue = currentValue
        self.maxValue = maxValue
    }
}
