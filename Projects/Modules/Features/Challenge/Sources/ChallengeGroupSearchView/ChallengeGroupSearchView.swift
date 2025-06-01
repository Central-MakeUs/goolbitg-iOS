//
//  ChallengeGroupSearchView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 5/30/25.
//

import SwiftUI
import Utils
import FeatureCommon

struct ChallengeGroupSearchView: View {
    
    @State private var searchText: String = ""
    @State private var searchBarFocus: Bool = false
    @State private var searchBarBigTrigger: Bool = false
    
    var body: some View {
        contentView
    }
}

extension ChallengeGroupSearchView {
    private var contentView: some View {
        VStack {
            navigationView
            ScrollView {
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var navigationView: some View {
        HStack(spacing: 4) {
            
            if !searchBarBigTrigger {
                ImageHelper.back.asImage
                    .resizable()
                    .frame(width: 32, height: 32)
                    .asButton {
                        
                    }
            }
            HStack(spacing: 0) {
                DisablePasteTextField(
                    configuration: DisablePasteTextFieldConfiguration(
                        textColor: GBColor.white.asColor,
                        placeholder: TextHelper.groupChallengeTexts(
                            .findGroupChallengePlaceholder
                        ).text,
                        placeholderColor: GBColor.grey300.asColor,
                        edge: UIEdgeInsets(
                            top: 12,
                            left: SpacingHelper.md.pixel,
                            bottom: 12,
                            right: 4
                        ),
                        keyboardType: .default,
                        isSecureTextEntry: false
                    ),
                    text: $searchText,
                    isFocused: $searchBarFocus,
                    onCommit: nil
                )
                .fixedSize(horizontal: false, vertical: true)
                
                Image(systemName: "magnifyingglass")
                    .padding(.trailing, SpacingHelper.md.pixel)
            }
            .background(GBColor.grey600.asColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
            )
            .onChange(of: searchBarFocus) { newValue in
                withAnimation {
                    print(newValue)
                    searchBarBigTrigger = newValue
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    ChallengeGroupSearchView()
}
#endif
