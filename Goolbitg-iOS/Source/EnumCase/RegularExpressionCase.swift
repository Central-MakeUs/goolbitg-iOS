//
//  RegularExpressionCase.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation

enum RegularExpressionCase {
    
    /// 한글, 영문, 대소문자만
    case nickName
    
}

extension RegularExpressionCase {
    var pattern: String {
        switch self {
        case .nickName:
            "^[a-zA-Z가-힣]+$"
        }
    }
    
    func matchedPattern(_ string: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf8.count)
            return regex.firstMatch(in: string, options: [], range: range) != nil
        } catch {
            return false
        }
    }
}
