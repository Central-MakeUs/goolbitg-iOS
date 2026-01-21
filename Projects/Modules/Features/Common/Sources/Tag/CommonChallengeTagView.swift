//
//  CommonChallengeTagView.swift
//  FeatureCommon
//
//  Created by Jae hyung Kim on 1/21/26.
//

import SwiftUI
import Utils

/// 공통 챌린지 태그 뷰
public struct CommonChallengeTagView: View {
    
    private enum Layout {
        static let verticalPadding: CGFloat = 4
        static let horizontalPadding: CGFloat = SpacingHelper.sm.pixel
        static let backgroundColor = GBColor.white.asColor.opacity(0.15)
        static let textColor = GBColor.white.asColor
        static let textFont = FontHelper.body5.font
    }
    
    public let tag: String
    
    public var body: some View {
        content
    }
    
    public init(tag: String) {
        self.tag = tag
    }
}

extension CommonChallengeTagView {
    
    private var content: some View {
        textView
            .background(Layout.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
    private var textView: some View {
        Text(tag)
            .font(Layout.textFont)
            .foregroundStyle(Layout.textColor)
            .padding(.vertical, Layout.verticalPadding)
            .padding(.horizontal, Layout.horizontalPadding)
    }
}

#if DEBUG
#Preview {
    ZStack(alignment: .center) {
        CommonChallengeTagView(tag: "Text")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(GBColor.background1.asColor)
}
#endif
