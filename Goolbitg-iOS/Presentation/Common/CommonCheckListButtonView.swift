//
//  CommonCheckListButtonView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/27/25.
//

import SwiftUI

struct CommonCheckListConfiguration: Hashable, Identifiable {
    let id = UUID()
    
    var currentState: Bool
    let checkListTitle: String
    let subText: String?
}

extension CommonCheckListConfiguration {
    var currentStateTextColor: Color {
        return currentState ? GBColor.main.asColor : GBColor.white.asColor
    }
    
    var currentStateSubTextColor: Color {
        return currentState ? GBColor.main50.asColor : GBColor.grey400.asColor
    }
    
    var backgroundColor: Color {
        return currentState ? GBColor.main20.asColor : GBColor.grey700.asColor
    }
    var strokeColor: Color {
        return currentState ? GBColor.main15.asColor : GBColor.grey500.asColor
    }
}

struct CommonCheckListButtonView: View {
    
    let configuration: CommonCheckListConfiguration
    
    var body: some View {
        content
            .background(configuration.backgroundColor)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(configuration.strokeColor)
            }
    }
}

extension CommonCheckListButtonView {
    private var content: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                Image(uiImage: configuration.currentState ? ImageHelper.checked.image : ImageHelper.unChecked.image)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 8)
                
                Text(configuration.checkListTitle)
                    .font(FontHelper.body4.font)
                    .foregroundStyle(configuration.currentStateTextColor)
                
                Spacer()
                
                if let sub = configuration.subText {
                    Text(sub)
                        .font(FontHelper.body5.font)
                        .foregroundStyle(configuration.currentStateSubTextColor)
                }
            }
            .padding(.horizontal, SpacingHelper.md.pixel)
            .padding(.vertical, 12)
        }
    }
}

#if DEBUG
#Preview {
    CommonCheckListButtonView(
        configuration: CommonCheckListConfiguration(
            currentState: false,
            checkListTitle: "롯데라아",
            subText: "미꾸도 나루도"
        )
    )
}
#endif
