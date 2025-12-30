//
//  SkeletonModifier.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import SwiftUI

struct SkeletonModifier: ViewModifier {
    
    let active: Bool /*= true*/
    let animation: Animation /*= ShimmerAnimation.defaultAnimation,*/
    let gradient: Gradient
    let bandSize: CGFloat /*= 0.3*/
    
    init(
        active: Bool = true,
        animation: Animation = ShimmerAnimation.defaultAnimation,
        bandSize: CGFloat = 0.3 ,
        gradient: Gradient = Gradient(colors: [
            Color.gray.opacity(0.3),
            Color.gray.opacity(0.1),
            Color.gray.opacity(0.3)
        ])
    ) {
        self.active = active
        self.animation = animation
        self.bandSize = bandSize
        self.gradient = gradient
    }
    
    func body(content: Content) -> some View {
        content
            .redacted(reason: .placeholder) // 모자이크
            .shimmering(active: active, animation: animation, gradient: gradient, bandSize: bandSize) // 쉬머링 효과 추가
    }
}
