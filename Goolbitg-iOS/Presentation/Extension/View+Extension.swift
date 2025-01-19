//
//  View+Extension.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import SwiftUI

extension View {
    func asButton(action: @escaping () -> Void ) -> some View {
        modifier(ButtonWrapper(action: action))
    }
    
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edge: edges).foregroundColor(color))
    }
    
    func cornerRadiusCorners(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        self
            .clipShape(
                RoundedCornerShape(corners: corners, radius: radius)
            )
    }
    
    @ViewBuilder
    func changeTextColor(_ color: Color) -> some View {
        if UITraitCollection.current.userInterfaceStyle == .light {
            self.colorInvert().colorMultiply(color)
        } else {
            self.colorMultiply(color)
        }
    }
}

// MARK: 뒤로가기 제스처
extension View {
    func disableBackGesture(_ disabled: Bool = true) -> some View {
        self.modifier(DisableBackGesture(isGestureDisabled: disabled))
    }
}
