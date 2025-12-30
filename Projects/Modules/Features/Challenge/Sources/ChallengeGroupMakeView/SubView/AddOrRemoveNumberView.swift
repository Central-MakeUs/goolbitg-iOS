//
//  AddOrRemoveNumberView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 5/28/25.
//

import SwiftUI
import Utils

struct AddOrRemoveNumberView: View {
    
    private var currentLeadingButtonState: Bool
    private var currentNumber: Int
    private var currentTrailingButtonState: Bool

    var onTappedCurrentLeadingButtonState: () -> Void
    var onTappedCurrentTrailingButtonState: () -> Void
    
    init(
        currentLeadingButtonState: Bool,
        currentNumber: Int,
        currentTrailingButtonState: Bool,
        onTappedCurrentLeadingButtonState: @escaping () -> Void,
        onTappedCurrentTrailingButtonState: @escaping () -> Void
    ) {
        self.currentLeadingButtonState = currentLeadingButtonState
        self.currentNumber = currentNumber
        self.currentTrailingButtonState = currentTrailingButtonState
        self.onTappedCurrentLeadingButtonState = onTappedCurrentLeadingButtonState
        self.onTappedCurrentTrailingButtonState = onTappedCurrentTrailingButtonState
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if currentLeadingButtonState {
                makeButtonView(text: "-", state: currentLeadingButtonState)
                    .asButton {
                        onTappedCurrentLeadingButtonState()
                    }
            }
            else {
                makeButtonView(text: "-", state: currentLeadingButtonState)
            }
            
            
            Text(String(currentNumber))
                .font(FontHelper.body2.font)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
            
            if currentTrailingButtonState {
                makeButtonView(text: "+", state: currentTrailingButtonState)
                    .asButton {
                        onTappedCurrentTrailingButtonState()
                    }
            }
            else {
                makeButtonView(text: "+", state: currentTrailingButtonState)
            }
        }
    }
    
    @ViewBuilder
    private func makeButtonView(text: String, state: Bool) -> some View {
        Text(text)
            .font(Font.system(size: 17, weight: .medium, design: .default))
            .foregroundStyle(
                state ? GBColor.disabledBG.asColor : GBColor.disabledText.asColor
            )
            .frame(width: 32, height: 32)
            .background(
                state ? .white : GBColor.disabledBG.asColor
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(GBColor.disabledText.asColor, lineWidth: 1)
                    .opacity(state ? 0 : 1)
            )
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    AddOrRemoveNumberView(
        currentLeadingButtonState: false,
        currentNumber: 2,
        currentTrailingButtonState: true
    ) {
        
    } onTappedCurrentTrailingButtonState: {
        
    }
    .background(.black)
}
#endif
