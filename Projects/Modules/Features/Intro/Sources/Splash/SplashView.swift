//
//  SplashView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/16/25.
//

import SwiftUI
import ComposableArchitecture
import Utils

struct SplashView: View {
    
    @Perception.Bindable var store: StoreOf<SplashFeature>
    
    var body: some View {
        VStack(spacing: 0) {

            ImageHelper.appLogo2.asImage
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
            store.send(.viewCycle(.onAppear))
        }
    }
}
