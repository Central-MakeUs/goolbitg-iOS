//
//  GBBottomSheetView.swift
//  FeatureCommon
//
//  Created by Jae hyung Kim on 5/23/25.
//

import SwiftUI
import Utils

public struct GBBottomSheetView: View {
    
    public let headerView: AnyView?
    public let contentView: AnyView
    
    public init(
        @ViewBuilder headerView: () -> AnyView? = { nil },
        @ViewBuilder contentView: () -> AnyView
    ) {
        self.headerView = headerView()
        self.contentView = contentView()
    }
    
    public var body: some View {
        content
    }
}

extension GBBottomSheetView {
    private var content: some View {
        VStack(spacing: 0) {
            headView
            contentView
        }
    }
    
    private var headView: some View {
        VStack( alignment: .center, spacing: 0) {
            Capsule()
                .foregroundStyle(GBColor.grey300.asColor)
                .frame(width: 32, height: 4)
                .padding(.all, SpacingHelper.md.pixel)
            if let headerView {
                headerView
            }
            Divider()
                .foregroundStyle(GBColor.grey300.asColor)
        }
    }
}
