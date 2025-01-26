//
//  GBBottonSheetView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/26/25.
//

import SwiftUI

struct GBBottonSheetView: View {
    
    let headerView: AnyView?
    let contentView: AnyView
    
    init(
        @ViewBuilder headerView: () -> AnyView? = { nil },
        @ViewBuilder contentView: () -> AnyView
    ) {
        self.headerView = headerView()
        self.contentView = contentView()
    }
    
    var body: some View {
        content
    }
}

extension GBBottonSheetView {
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
