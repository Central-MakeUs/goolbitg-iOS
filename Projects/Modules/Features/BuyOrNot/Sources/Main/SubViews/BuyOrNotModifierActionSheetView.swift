//
//  BuyOrNotModifierActionSheetView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 4/8/26.
//

import SwiftUI
import Utils
import FeatureCommon

struct BuyOrNotModifierActionSheetView: View {

    let safeAreaBottom: CGFloat
    let onModify: () -> Void
    let onDelete: () -> Void
    let onClose: () -> Void

    var body: some View {
        GBBottomSheetView {
            AnyView(topContent)
        } contentView: {
            AnyView(bottomContent)
        }
        .frame(maxWidth: .infinity)
        .background(GBColor.grey700.asColor)
        .cornerRadiusCorners(12, corners: [.topLeft, .topRight])
    }
}

private extension BuyOrNotModifierActionSheetView {

    var topContent: some View {
        VStack(spacing: 0) {
            actionRow(title: "수정하기", color: GBColor.white.asColor, action: onModify)

            Divider()
                .padding(.vertical, SpacingHelper.sm.pixel)
                .padding(.horizontal, SpacingHelper.md.pixel)

            actionRow(title: "삭제하기", color: GBColor.error.asColor, action: onDelete)
        }
        .padding(.vertical, SpacingHelper.md.pixel)
    }

    var bottomContent: some View {
        VStack(spacing: 0) {
            Text("닫기")
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
                .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .background(GBColor.grey600.asColor)
        .clipShape(Capsule())
        .padding(.all, 16)
        .asButton {
            onClose()
        }
        .padding(.bottom, safeAreaBottom)
    }

    func actionRow(title: String, color: Color, action: @escaping () -> Void) -> some View {
        HStack {
            Spacer()
            Text(title)
                .font(FontHelper.body1.font)
                .foregroundStyle(color)
                .padding(.vertical, SpacingHelper.sm.pixel)
            Spacer()
        }
        .asButton {
            action()
        }
        .padding(.horizontal, SpacingHelper.lg.pixel)
    }
}
