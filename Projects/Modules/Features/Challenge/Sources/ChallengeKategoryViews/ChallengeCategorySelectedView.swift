//
//  ChallengeCategorySelectedView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 10/4/25.
//

import SwiftUI
import FeatureCommon
import Utils

struct ChallengeCategorySelectedView: View {
    
    @Binding var text: String
    @State var isScrolling: Bool = false
    let categories: [String]
    @State private var isOn: Bool = false
    @State private var topViewHeight = CGFloat(0)
    
    var body: some View {
        content
    }
}

extension ChallengeCategorySelectedView {
    var content: some View {
        topView
            .readHeight { height in
                topViewHeight = height
            }
            .overlay(alignment: .top) {
                if isOn {
                    bottomListView
                }
            }
            .zIndex(isOn ? 1 : 0)
    }
    
    private var topView: some View {
        VStack(spacing: 0) {
            sectionTopTextView(text: "카테고리")
            HStack {
                Text(text.isEmpty ? "카테고리 선택하기" : text)
                    .foregroundStyle(text.isEmpty ? GBColor.grey400.asColor : GBColor.white.asColor)
                    .font(FontHelper.caption2.font)
                Spacer()
                
                ImageHelper.chevronDown.asImage
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(GBColor.grey400.asColor)
            }
            .padding(.all, SpacingHelper.md.pixel)
            .background(GBColor.grey600.asColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
            )
            .asButton {
                withAnimation {
                    isOn.toggle()
                }
            }
        }
    }
    
    
    private func sectionTopTextView(
        text: String,
        subText: String? = nil
    ) -> some View {
        HStack(spacing: 3) {
            Text(text)
                .font(FontHelper.caption1.font)
                .foregroundStyle(GBColor.white.asColor)

                Text("*")
                    .font(FontHelper.caption1.font)
                    .foregroundStyle(GBColor.error.asColor)

            if let subText {
                Text(subText)
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.grey300.asColor)
            }
            Spacer()
        }
    }
    
    private func listElementView(text: String) -> some View {
        HStack {
            Text(text)
                .font(FontHelper.caption1.font)
                .foregroundStyle(GBColor.white.asColor)
            Spacer()
        }
    }
}

extension ChallengeCategorySelectedView {
    private var bottomListView: some View {
        ScrollView {
            VStack(spacing: SpacingHelper.sm.pixel) {
                ForEach(Array(categories.enumerated()), id: \.element.self) { index, text in
                    VStack(spacing: 0) {
                        listElementView(text: text)
                            
                        if index != categories.count - 1 {
                            GBColor.grey500.asColor
                                .frame(maxWidth: .infinity)
                                .frame(height: 1)
                                .padding(.top, SpacingHelper.sm.pixel)
                        }
                    }
                    .asButton {
                        withAnimation {
                            isOn = false
                        }
                        self.text = text
                    }
                }
            }
            .padding(.top, SpacingHelper.md.pixel)
            .padding(.horizontal, SpacingHelper.md.pixel)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 196)
        .background(GBColor.grey600.asColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
        )
        .padding(.top, topViewHeight + SpacingHelper.sm.pixel)
        .gesture (
            DragGesture(minimumDistance: 0, coordinateSpace: .global) // Scroll Event Catch
        )
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    @Previewable @State var text = ""
    
    ChallengeCategorySelectedView(
        text: $text,
        categories: [
            "식비",
            "교통비",
            "쇼핑",
            "기타",
            "생활비"
        ]
    )
    .padding(.horizontal, 8)
    .background(GBColor.background1.asColor)
}
#endif
