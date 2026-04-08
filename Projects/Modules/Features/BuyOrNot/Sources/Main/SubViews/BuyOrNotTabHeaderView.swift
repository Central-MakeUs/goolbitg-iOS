//
//  BuyOrNotTabHeaderView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 4/8/26.
//

import SwiftUI
import Utils

struct BuyOrNotTabHeaderView: View {

    let currentTab: BuyOrNotTabInMode
    let onTabSelected: (BuyOrNotTabInMode) -> Void
    let onAddTapped: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(BuyOrNotTabInMode.buyOrNot.title)
                .font(headerTitleFont(mode: .buyOrNot))
                .foregroundStyle(headerTitleColor(mode: .buyOrNot))
                .asButton {
                    onTabSelected(.buyOrNot)
                }
                .padding(.trailing, 4)

            Text(BuyOrNotTabInMode.records.title)
                .font(headerTitleFont(mode: .records))
                .foregroundStyle(headerTitleColor(mode: .records))
                .asButton {
                    onTabSelected(.records)
                }

            Spacer()

            ImageHelper.buyOrNotAdd.asImage
                .resizable()
                .frame(width: 38, height: 38)
                .asLiquidGlassButton {
                    onAddTapped()
                }
        }
    }
}

private extension BuyOrNotTabHeaderView {

    func headerTitleColor(mode: BuyOrNotTabInMode) -> Color {
        mode == currentTab ? GBColor.white.asColor : GBColor.grey400.asColor
    }

    func headerTitleFont(mode: BuyOrNotTabInMode) -> Font {
        mode == currentTab ? FontHelper.h1.font : FontHelper.h2.font
    }
}
