//
//  HapTicManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import UIKit

public final class HapticFeedbackManager: Sendable {
    @MainActor
    public func notificationStyle(type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    @MainActor
    public func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    private init() {}
}

extension HapticFeedbackManager {
    public static let shared = HapticFeedbackManager()
}
