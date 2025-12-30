//
//  ShimmerAnimation.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import SwiftUI

public struct ShimmerAnimation: ViewModifier {
    
    public enum Mode {
        case mask
        case overlay(blendMode: BlendMode = .sourceAtop)
        case background
    }

    private let animation: Animation
    private let gradient: Gradient
    private let min, max: CGFloat
    private let mode: Mode
    @State private var isInitialState = true
    @Environment(\.layoutDirection) private var layoutDirection // leading 방향인지 아닌지
    
    
    public static let defaultAnimation = Animation.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false)
    public static let defaultGradient = Gradient(colors: [
        .black.opacity(0.3), // translucent
        .black, // opaque
        .black.opacity(0.3) // translucent
    ])
    
    public init(
        animation: Animation = Self.defaultAnimation,
        gradient: Gradient = Self.defaultGradient,
        bandSize: CGFloat = 0.3,
        mode: Mode = .mask
    ) {
        self.animation = animation
        self.gradient = gradient
        self.min = 0 - bandSize
        self.max = 1 + bandSize
        self.mode = mode
    }

    /*
     UnitPoint: 뷰 내부 영역 기준 좌표 정의
     */
    public var startPoint: UnitPoint {
        if layoutDirection == .rightToLeft {
            isInitialState ? UnitPoint(x: max, y: min) : UnitPoint(x: 0, y: 1)
        } else {
            isInitialState ? UnitPoint(x: min, y: min) : UnitPoint(x: 1, y: 1)
        }
    }

    public var endPoint: UnitPoint {
        if layoutDirection == .rightToLeft {
            isInitialState ? UnitPoint(x: 1, y: 0) : UnitPoint(x: min, y: max)
        } else {
            isInitialState ? UnitPoint(x: 0, y: 0) : UnitPoint(x: max, y: max)
        }
    }

    public func body(content: Content) -> some View {
        applyingGradient(to: content)
            .animation(animation, value: isInitialState)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()) { // 초기 레이아웃 잡힐때까지 애니메이션 지연
                    isInitialState = false
                }
            }
    }

    @ViewBuilder public func applyingGradient(to content: Content) -> some View {
        let gradient = LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
        switch mode {
        case .mask:
            content.mask(gradient)
        case let .overlay(blendMode: blendMode):
            content.overlay(gradient.blendMode(blendMode))
        case .background:
            content.background(gradient)
        }
    }
}


/*
    \
     ┌───────┐         ┌───────┐
     │0,0    │ Animate │       │  "forward" gradient
 LTR │       │ ───────►│    1,1│  / // /
     └───────┘         └───────┘
                                \
                              max,max
            max,min
              /
     ┌───────┐         ┌───────┐
     │    1,0│ Animate │       │  "backward" gradient
 RTL │       │ ───────►│0,1    │  \ \\ \
     └───────┘         └───────┘
                      /
                   min,max
 */

