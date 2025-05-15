//
//  SkeletonWrapper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import SwiftUI

struct SkeletonWrapper<Content: View>: View {
    let count: Int
    let animation: Animation
    let content: () -> Content

    init(
        count: Int,
        animation: Animation = ShimmerAnimation.defaultAnimation,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.count = count
        self.animation = animation
        self.content = content
    }

    var body: some View {
        VStack {
            ForEach(0..<count, id: \.self) { _ in
                content()
                    .skeletonEffect(animation: animation)
            }
        }
        .padding(.horizontal, 12)
    }
}
