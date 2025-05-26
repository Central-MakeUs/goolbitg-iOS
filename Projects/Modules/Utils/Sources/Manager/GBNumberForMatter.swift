//
//  GBNumberForMatter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/12/25.
//

import Foundation
import ComposableArchitecture

public final class GBNumberForMatter: Sendable {
    private let numberFormatter = NumberFormatter()
}

extension GBNumberForMatter {
    
    /// 문자열을 받아 숫자로 변환후 이를 , 단위로 분리합니다.
    /// - Parameter string: input ex) 1000
    /// - Returns: output ex) 1,000
    public func changeForCommaNumber(_ string: String) -> String {
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        
        let filter = filterForStringToNumber(string)
        
        if let number = Int(filter) {
            return numberFormatter.string(from: NSNumber(value: number)) ?? ""
        } else {
            return ""
        }
    }
    
    public func changeForCommaNumber(_ number: Double) -> String {
        return changeFormatToString(number: number)
    }
    
    public func changetForCommaNumber(_ number: String, max: Int) -> String {
        
        let filteredNumber = number.filter { $0.isNumber }
        
        if filteredNumber.isEmpty { return number }
        
        if let intValue = Int(filteredNumber) {
            // 자리수를 초과하면 원본 반환
            if filteredNumber.count > max {
                var number = number
                number.removeLast()
                return number
            }
            
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSeparator = ","
            
            return numberFormatter.string(from: NSNumber(value: intValue)) ?? number
        } else {
            return ""
        }
    }
    
    /// 문자열중 숫자인것만 필터합니다.
    /// - Parameter string: input
    /// - Returns: 필터된 문자열
    public func filterForStringToNumber(_ string: String) -> String {
        let filtered = string.filter { "0123456789".contains($0) }
        return filtered
    }
    
    public func changeFormatToString(
        number: Double,
        numberStyle: NumberFormatter.Style = .currency
    ) -> String {
        numberFormatter.numberStyle = numberStyle
        if numberStyle == .decimal {
            numberFormatter.groupingSeparator = ","
        }
        return numberFormatter.string(from: NSNumber(value: number)) ?? ""
    }
}

extension GBNumberForMatter {
    public static let shared = GBNumberForMatter()
}

extension GBNumberForMatter: DependencyKey {
    public static let liveValue: GBNumberForMatter = GBNumberForMatter()
}

extension DependencyValues {
    public var gbNumberForMatter: GBNumberForMatter {
        get { self[GBNumberForMatter.self] }
        set { self[GBNumberForMatter.self] = newValue }
    }
}
