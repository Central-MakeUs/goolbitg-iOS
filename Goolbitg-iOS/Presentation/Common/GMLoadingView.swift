//
//  GMLoadingView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import SwiftUI
import Lottie

struct GBLoadingView: View {
    
    var body: some View {
        content
    }
}

extension GBLoadingView {
    var content: some View {
        VStack(spacing: 0) {
            LottieView {
                try await DotLottieFile.named("GB_Loading_v8")
            }
            .playing(loopMode: .loop)
            .resizable()
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
