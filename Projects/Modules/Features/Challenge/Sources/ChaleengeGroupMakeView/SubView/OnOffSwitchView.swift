//
//  OnOffSwitchView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 5/28/25.
//

import SwiftUI
import Utils

struct OnOffSwitchView: View {
    
    @Binding var buttonState: Bool
    @State private var viewHeight: CGFloat = 0
    @State private var viewWidth: CGFloat = 0
    
    init(buttonState: Binding<Bool>) {
        self._buttonState = buttonState
    }
    
    var body: some View {
        contentView
    }
}

extension OnOffSwitchView {
    private var contentView: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("ON")
                        .opacity(buttonState ? 1 : 0)
                    Text("OFF")
                        .opacity(buttonState ? 0 : 1)
                }
                .font(FontHelper.body5.font)
                .foregroundStyle(buttonState ? GBColor.white.asColor : GBColor.grey300.asColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
            }
            .background(buttonState ? GBColor.main.asColor : GBColor.grey500.asColor)
            .clipShape(Capsule())
            .readHeight { height in
                viewHeight = height
            }
            .readWidth { width in
                viewWidth = width
            }
            
            HStack {
                if buttonState {
                    Spacer()
                }
                Circle()
                    .frame(width: viewHeight - 4, height: viewHeight - 4)
                    .foregroundStyle(GBColor.white.asColor)
                    .padding(.horizontal, 2)
                    .asButton {
                        buttonState.toggle()
                    }
                if !buttonState {
                    Spacer()
                }
            }
            .frame(width: viewWidth, height: viewHeight)
        }
        
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var test = false
    OnOffSwitchView(buttonState: $test)
}
