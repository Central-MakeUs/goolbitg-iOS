//
//  GBButton.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import SwiftUI
import Utils

public struct GBButton: View {
    
    @Binding public var isActionButtonState: Bool
    public let title: String
    public let onSubmit: () -> Void?
    
    public init(
        isActionButtonState: Binding<Bool>,
        title: String,
        onSubmit: @escaping () -> Void?
    ) {
        self._isActionButtonState = isActionButtonState
        self.title = title
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        VStack {
            if !isActionButtonState {
                HStack {
                    Text(title)
                        .foregroundStyle(GBColor.grey400.asColor)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(GBColor.grey500.asColor)
                .font(FontHelper.btn1.font)
                .clipShape(Capsule())
            } else {
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
    }
}
