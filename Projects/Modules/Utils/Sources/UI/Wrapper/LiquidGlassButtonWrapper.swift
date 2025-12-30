//
//  LiquidGlassButtonWrapper.swift
//  Utils
//
//  Created by Jae hyung Kim on 9/27/25.
//

import SwiftUI

public struct LiquidGlassButtonWrapper: ViewModifier {
    
    public let type: LiquidGlassButtonStyleType
    
    public let action: () -> Void
    
    /// LiquidGlassButtonWrapper init
    /// - Parameters:
    ///   - action: callBack
    public init(
        type: LiquidGlassButtonStyleType = .glass,
        action: @escaping () -> Void
    ) {
        self.type = type
        self.action = action
    }
    
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            switch type {
            case .glass:
                button(content)
                    .buttonStyle(.glass)
            case .glassProminent:
                button(content)
                    .buttonStyle(.glassProminent)
            }
        } else {
            content
                .modifier(ButtonWrapper(action: action))
        }
    }
    
    private func button(_ content: Content) -> some View {
        Button(
            action: action,
            label: {
                content
                    .contentShape(Rectangle())
                    .background(Color.clear)
            }
        )
    }
}

public enum LiquidGlassButtonStyleType {
    case glass
    case glassProminent
}
