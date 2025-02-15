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

extension View {
    
    func snapshot(scale: CGFloat? = nil) -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale ?? UIScreen.main.scale
        return renderer.uiImage
    }
    
    func asImage() -> Image {
        let image = self.snapshot()
        return Image(uiImage: image ?? UIImage())
    }
}

extension View {
    @ViewBuilder func shimmering(
        active: Bool = true,
        animation: Animation = ShimmerAnimation.defaultAnimation,
        gradient: Gradient = ShimmerAnimation.defaultGradient,
        bandSize: CGFloat = 0.3,
        mode: ShimmerAnimation.Mode = .mask
    ) -> some View {
        if active {
            modifier(ShimmerAnimation(animation: animation, gradient: gradient, bandSize: bandSize, mode: mode))
        } else {
            self
        }
    }
    
    func skeletonEffect(
        animation: Animation = ShimmerAnimation.defaultAnimation,
        gradient: Gradient = ShimmerAnimation.defaultGradient,
        bandSize: CGFloat = 0.3
    ) -> some View {
        self.modifier(SkeletonModifier(animation: animation, bandSize: bandSize, gradient: gradient))
    }
}

// MARK: 뒤로가기 제스처
extension View {
    func disableBackGesture(_ disabled: Bool = true) -> some View {
        self.modifier(DisableBackGesture(isGestureDisabled: disabled))
    }
}


// MARK: Font 중앙화
extension Text {
    func asFont(_ helper: FontHelper) -> Text {
        return self.font(helper.font)
    }
}
