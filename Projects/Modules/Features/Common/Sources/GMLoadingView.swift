//
//  GMLoadingView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import SwiftUI
import Utils

public struct GBLoadingView: View {
    public init () {}
    public var body: some View {
        content
    }
}

extension GBLoadingView {
    private var content: some View {
        VStack(spacing: 0) {
//            LottieView {
//                try await DotLottieFile.named("GB_Loading_v8")
//            }
//            .playing(loopMode: .loop)
//            .resizable()
            LottieBridgeView(
                dotLottieFileName: "GB_Loading_v8",
                loopMode: .loop
            )
            .padding(.horizontal, 150)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .ignoresSafeArea()
    }
}

#if DEBUG
#Preview {
    GBLoadingView()
}
#endif
