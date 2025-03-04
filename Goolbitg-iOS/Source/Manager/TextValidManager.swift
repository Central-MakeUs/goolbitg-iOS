//
//  TextValidManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/17/25.
//

import Foundation
import ComposableArchitecture

final class TextValidManager: Sendable {
    enum TextValidMode {
        case nickNameKoreanAndEnglish
        
    }
    
    enum TextRegex: String {
        case koreanEnglish = "^[a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣]+$"
    }
}

extension TextValidManager {
    
    func textValidCheck(validMode: TextValidMode, text: String) -> Bool {
        switch validMode {
        case .nickNameKoreanAndEnglish:
            
            return checkRegex(modes: .koreanEnglish, text: text)
        }
    }
}

extension TextValidManager {
    
    private func checkRegex(modes: TextRegex... , text: String) -> Bool {
        let combinedPattern = modes.map { $0.rawValue }.joined(separator: "|")
        
        guard let regex = try? NSRegularExpression(pattern: combinedPattern) else {
            return false // 정규식 생성 실패 시
        }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }
}

extension TextValidManager: DependencyKey {
    static let liveValue: TextValidManager = TextValidManager()
}
extension DependencyValues {
    var textValidManager: TextValidManager {
        get { self[TextValidManager.self] }
        set { self[TextValidManager.self] = newValue }
    }
}
