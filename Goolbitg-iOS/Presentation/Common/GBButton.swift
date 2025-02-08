//
//  GBButton.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import SwiftUI

struct GBButton: View {
    
    @Binding var isActionButtonState: Bool
    let title: String
    let onSubmit: () -> Void?
    
    var body: some View {
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

struct GBButtonV2: View {
    
    let title: String
    let onSubmit: () -> Void?
    
    var body: some View {
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
