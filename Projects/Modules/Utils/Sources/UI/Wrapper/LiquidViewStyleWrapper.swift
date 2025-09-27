//
//  LiquidViewStyleWrapper.swift
//  Utils
//
//  Created by Jae hyung Kim on 9/27/25.
//

import SwiftUI

public struct LiquidViewStyleWrapper: ViewModifier {
    
    public let type: LiquidGlassType
    public let shape: any Shape
    
    /// LiquidViewStyleWrapper init
    /// - Parameters:
    ///   - type: LiquidGlassType
    ///   - defaultShape: iff True -> DefaultGlassEffectShape() So ignored Shape
    ///   - shape: CustomShape
    public init(
        _ type: LiquidGlassType,
        defaultShape: Bool = true,
        shape: some Shape = .capsule
    ) {
        self.type = type
        if #available(iOS 26.0, *) {
            self.shape = DefaultGlassEffectShape()
        } else {
            self.shape = shape
        }
    }
    
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(glassEffect(type), in: shape)
        } else {
            content
        }
    }
}

// MARK: UI Logic
extension LiquidViewStyleWrapper {
    
    @available(iOS 26.0, *)
    private func glassEffect(_ type: LiquidGlassType) -> Glass {
        switch type {
        case .clear:
            return .clear
        case .identity:
            return .identity
        case .regular:
            return .regular
        }
    }
}

public enum LiquidGlassType: Equatable, Hashable, Sendable {
    
    case regular
    
    case clear
    
    case identity
}
