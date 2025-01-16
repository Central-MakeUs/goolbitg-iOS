//
//  SplashView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/16/25.
//

import SwiftUI

struct SplashView: View {
 
    let onAppearTrigger: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {

            Image(uiImage: ImageHelper.appLogo2.image)
                .resizable()
                .frame(width: 117, height: 143)
                .offset(x: 20)
                .padding(.top, 178)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background {
            Image(uiImage: ImageHelper.splashBack.image)
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .ignoresSafeArea()
        }
        .onAppear {
            onAppearTrigger()
        }
    }
}

#Preview {
    SplashView {
        
    }
}
