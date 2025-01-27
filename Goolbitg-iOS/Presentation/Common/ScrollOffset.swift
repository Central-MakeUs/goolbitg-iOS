//
//  ScrollOffset.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/27/25.
//

import SwiftUI

struct ScrollViewOffsetPreference: View {
    let onOffsetChange: (CGFloat) -> Void
    
    init(onOffsetChange: @escaping (CGFloat) -> Void) {
        self.onOffsetChange = onOffsetChange
    }
    
    var body: some View {
        GeometryReader { proxy in
            let offsetY = proxy.frame(in: .global).origin.y
            Color.clear
                .preference(
                    key: ScrollOffsetKey.self,
                    value: offsetY
                )
                .onAppear {
                    onOffsetChange(offsetY)
                }
        }
        .frame(height: 0)
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
