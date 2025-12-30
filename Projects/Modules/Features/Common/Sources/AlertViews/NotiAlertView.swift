//
//  NotiAlertView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/8/25.
//

import SwiftUI
import Utils

public struct NotiAlertView: View {
    
    @Binding public var notiCount: Int
    
    public init(notiCount: Binding<Int>) {
        self._notiCount = notiCount
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: ImageHelper.bell.image)
                .resizable()
                .frame(width: 24, height: 24)
                
            if notiCount > 0 {
                ZStack {
                    Circle()
                        .foregroundStyle(GBColor.error.asColor)
                    Text(notiCount.toString)
                        .font(.system(size: 11, weight: .medium, design: .default))
                        .foregroundStyle(GBColor.white.asColor)
                }
                .frame(width: 16, height: 16)
                .offset(y: -5)
                .offset(x: 5)
            }
        }
    }
}
