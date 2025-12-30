//
//  ScrollViewOffsetPreference.swift
//  Utils
//
//  Created by Jae hyung Kim on 5/23/25.
//

import SwiftUI

public struct ScrollViewOffsetPreference: View {
    public let onOffsetChange: (CGFloat) -> Void
    
    public init(onOffsetChange: @escaping (CGFloat) -> Void) {
        self.onOffsetChange = onOffsetChange
    }
    
    public var body: some View {
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

public struct ScrollOffsetKey: PreferenceKey, @unchecked Sendable {
    nonisolated(unsafe) public static var defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
