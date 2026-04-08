//
//  BuyOrNotEmptyStateView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 4/8/26.
//

import SwiftUI
import Utils
import FeatureCommon

struct BuyOrNotEmptyStateView: View {

    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ImageHelper.appLogo.asImage
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .grayscale(1)

            Text("아직 작성된 글이 없어요")
                .font(FontHelper.body2.font)
                .foregroundStyle(GBColor.grey200.asColor)
                .padding(.bottom, SpacingHelper.lg.pixel)

            GBButtonV2(title: "살까말까 글 작성하기") {
                action()
            }
        }
        .padding(.top, 40)
        .frame(width: UIScreen.main.bounds.width / 2)
    }
}
