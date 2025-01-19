//
//  GBChallengeBottomSheetView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import SwiftUI

struct GBChallengeBottomSheetView: View {
    
    var body: some View {
        content
            .background(GBColor.grey600.asColor)
            .cornerRadiusCorners(28, corners: [.topLeft, .topRight])
    }
}

extension GBChallengeBottomSheetView {
    
    private var content: some View {
        VStack(spacing: 0) {
            headView
                .frame(maxWidth: .infinity)
            middleContent
            
            Divider()
                .foregroundStyle(GBColor.grey300.asColor)
            
            challengeButton
                .padding(.bottom, 20)
        }
    }
    
    private var headView: some View {
        VStack( alignment: .center, spacing: 0) {
            Capsule()
                .foregroundStyle(GBColor.grey300.asColor)
                .frame(width: 32, height: 4)
                .padding(.all, SpacingHelper.md.pixel)
            Divider()
                .foregroundStyle(GBColor.grey300.asColor)
        }
    }
    
    private var middleContent: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(uiImage: ImageHelper.appLogo.image)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 160)
                .grayscale(1)
                .background(GBColor.grey500.asColor)
                .clipShape(Circle())
            
            Text("커피 값 모아 태산")
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.grey50.asColor)
                .padding(.vertical, SpacingHelper.xs.pixel)
            HStack(spacing: 0) {
                ForEach(["#모닝커피", "#직딩", "#모닝커피", "#직딩"], id: \.self) { item in
                    Text(item)
                        .font(FontHelper.body5.font)
                        .foregroundStyle(GBColor.grey200.asColor)
                        .padding(.trailing, 1)
                }
            }
        }
        .padding(.all, SpacingHelper.md.pixel)
    }
    
    private var challengeButton: some View {
        VStack (spacing: 0) {
            GBButtonV2(title: "도전하기") {
                
            }
            .padding(.all, SpacingHelper.md.pixel)
        }
    }
}

#Preview {
    GBChallengeBottomSheetView()
}
