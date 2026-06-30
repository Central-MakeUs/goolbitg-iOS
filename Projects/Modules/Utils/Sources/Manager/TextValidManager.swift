//
//  TextValidManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/17/25.
//

import Foundation
import ComposableArchitecture

public final class TextValidManager: Sendable {
    public enum TextValidMode {
        case nickNameKoreanAndEnglish
    }

    public enum TextNormalizeMode {
        case chatMessage
    }

    public enum TextRegex: String {
        case koreanEnglish = "^[a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣]+$"
    }

    private static let chatMessageMaxCharacterCount = 500
    private static let chatMessageMaxLineCount = 5
}

extension TextValidManager {
    public func textValidCheck(validMode: TextValidMode, text: String) -> Bool {
        switch validMode {
        case .nickNameKoreanAndEnglish:
            return checkRegex(modes: .koreanEnglish, text: text)
        }
    }

    public func normalizedText(normalizeMode: TextNormalizeMode, text: String) -> String {
        switch normalizeMode {
        case .chatMessage:
            return normalizedChatMessage(text)
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

    private func normalizedChatMessage(_ text: String) -> String {
        let normalizedNewlines = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let limitedLines = normalizedNewlines
            .components(separatedBy: "\n")
            .prefix(Self.chatMessageMaxLineCount)
            .map(removeUnsafeScalars)
            .joined(separator: "\n")

        guard limitedLines.count > Self.chatMessageMaxCharacterCount else {
            return limitedLines
        }
        let endIndex = limitedLines.index(
            limitedLines.startIndex,
            offsetBy: Self.chatMessageMaxCharacterCount
        )
        return String(limitedLines[..<endIndex])
    }

    private func removeUnsafeScalars(_ text: String) -> String {
        String(
            text.unicodeScalars.filter { scalar in
                scalar.properties.generalCategory != .control &&
                scalar.properties.generalCategory != .format
            }
        )
    }
}

extension TextValidManager: DependencyKey {
    public static let liveValue: TextValidManager = TextValidManager()
    public static let testValue: TextValidManager = TextValidManager()
}
extension DependencyValues {
    public var textValidManager: TextValidManager {
        get { self[TextValidManager.self] }
        set { self[TextValidManager.self] = newValue }
    }
}
