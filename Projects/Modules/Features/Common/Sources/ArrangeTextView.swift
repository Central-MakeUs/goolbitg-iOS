//
//  ArrangeTextView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/1/25.
//

import SwiftUI

public struct ArrangeTextView: View {
    
    public let text: String
    public let defaultFont: Font
    public let type: TextArrangeType
    public let targetFont: Font?
    
    public enum TextArrangeType {
        case big
        case mid
        
        var pattern: String {
            switch self {
            case .big:
                return "\\[.*?\\]"
            case .mid:
                return  "\\{.*?\\}"
            }
        }
    }
    
    public var body: some View {
        parseText()
    }
}

extension ArrangeTextView {
    
    /// 정규식을 이용하여 텍스트를 분해하고, 특정 부분의 폰트를 변경하는 함수
    private func parseText() -> Text {
        guard let regex = try? NSRegularExpression(pattern: type.pattern, options: []) else {
            return Text(text).font(defaultFont)
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        var resultText = Text("")
        var lastIndex = 0
        
        for match in matches {
            let range = match.range
            let beforeText = nsString.substring(with: NSRange(location: lastIndex, length: range.location - lastIndex))
            let targetText = nsString.substring(with: range)
            
            resultText = resultText + Text(beforeText).font(defaultFont)
            resultText = resultText + Text(targetText).font(targetFont ?? defaultFont)
            
            lastIndex = range.location + range.length
        }
        
        let remainingText = nsString.substring(from: lastIndex)
        resultText = resultText + Text(remainingText).font(defaultFont)
        
        return resultText
    }
    
}
