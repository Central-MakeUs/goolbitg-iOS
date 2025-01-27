//
//  GBNumberForMatter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/12/25.
//

import Foundation
import ComposableArchitecture

final class GBNumberForMatter: Sendable {
    private let numberFormatter = NumberFormatter()
}

extension GBNumberForMatter {
    
    /// 문자열을 받아 숫자로 변환후 이를 , 단위로 분리합니다.
    /// - Parameter string: input ex) 1000
    /// - Returns: output ex) 1,000
    func changeForCommaNumber(_ string: String) -> String {
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        
        let filter = filterForStringToNumber(string)
        
        if let number = Int(filter) {
            return numberFormatter.string(from: NSNumber(value: number)) ?? ""
        } else {
            return ""
        }
    }
    
    /// 문자열중 숫자인것만 필터합니다.
    /// - Parameter string: input
    /// - Returns: 필터된 문자열
    func filterForStringToNumber(_ string: String) -> String {
        let filtered = string.filter { "0123456789".contains($0) }
        return filtered
    }
    
    func changeFormatToString(
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
    static let shared = GBNumberForMatter()
}

extension GBNumberForMatter: DependencyKey {
    static let liveValue: GBNumberForMatter = GBNumberForMatter()
}

extension DependencyValues {
    var gbNumberForMatter: GBNumberForMatter {
        get { self[GBNumberForMatter.self] }
        set { self[GBNumberForMatter.self] = newValue }
    }
}
