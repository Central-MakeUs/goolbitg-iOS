//
//  HapTicManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import UIKit

final class HapticFeedbackManager: Sendable {
    @MainActor
    func notificationStyle(type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    @MainActor
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

extension HapticFeedbackManager {
    static let shared = HapticFeedbackManager()
}
