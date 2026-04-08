//
//  BuyOrNotModifyBottomSheetView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import SwiftUI
import Utils
import Data
import FeatureCommon

struct BuyOrNotModifyBottomSheetView: View {

    @State private var ifCurrentReportCase: ReportCase?
    @State private var currentButtonState = false
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    let reportButtonTapped: (ReportCase) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .foregroundStyle(GBColor.grey300.asColor)
                .frame(width: 32, height: 4)
                .padding(.top, SpacingHelper.md.pixel)
                .padding(.horizontal, SpacingHelper.md.pixel)

            reportHeaderView

            Divider()
                .foregroundStyle(GBColor.grey300.asColor)
                .padding(.bottom, SpacingHelper.sm.pixel)

            reportFooterView
        }
        .frame(maxWidth: .infinity)
        .background(GBColor.grey600.asColor)
        .cornerRadiusCorners(12, corners: [.topLeft, .topRight])
    }
}

private extension BuyOrNotModifyBottomSheetView {

    var reportFooterView: some View {
        VStack(spacing: 0) {
            LazyVStack(spacing: SpacingHelper.md.pixel) {
                ForEach(ReportCase.allCases, id: \.self) { item in
                    CommonCheckListButtonView(
                        configuration: CommonCheckListConfiguration(
                            currentState: ifCurrentReportCase == item,
                            checkListTitle: item.reason,
                            subText: nil
                        )
                    )
                    .asButton {
                        if ifCurrentReportCase == item {
                            ifCurrentReportCase = nil
                            currentButtonState = false
                        } else {
                            ifCurrentReportCase = item
                            currentButtonState = true
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            Divider()
                .foregroundStyle(GBColor.grey300.asColor)
                .padding(.top, SpacingHelper.sm.pixel)

            GBButton(isActionButtonState: $currentButtonState, title: "신고하기") {
                if let ifCurrentReportCase {
                    reportButtonTapped(ifCurrentReportCase)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.all, 16)
            .padding(.bottom, safeAreaInsets.bottom)
        }
    }

    var reportHeaderView: some View {
        VStack(spacing: 4) {
            HStack {
                Spacer()
                Text("신고하기")
                    .font(FontHelper.h3.font)
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }

            HStack {
                Spacer()
                Text("신고하려는 이유를 선택해 주세요")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.grey200.asColor)
                Spacer()
            }
        }
        .padding(.all, SpacingHelper.sm.pixel)
    }
}
