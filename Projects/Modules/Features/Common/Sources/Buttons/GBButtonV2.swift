//
//  GBButtonV2.swift
//  FeatureCommon
//
//  Created by Jae hyung Kim on 5/23/25.
//

import SwiftUI
import Utils

public struct GBButtonV2: View {
    
    public let title: String
    public let onSubmit: () -> Void?
    
    public init(title: String, onSubmit: @escaping () -> Void?) {
        self.title = title
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        HStack {
            Text(title)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background {
            Rectangle()
                .fill(
                    .linearGradient(colors: [
                        GBColor.primary600.asColor,
                        GBColor.primary400.asColor
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
        .clipShape(Capsule())
        .font(FontHelper.btn1.font)
        .foregroundStyle(GBColor.white.asColor)
        .clipShape(Capsule())
        .asButton {
            onSubmit()
        }
    }
}
