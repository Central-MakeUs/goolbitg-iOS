//
//  ButtonWrapper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import SwiftUI

public struct ButtonWrapper: ViewModifier {
    
    public let action: () -> Void
    
    public func body(content: Content) -> some View {
        Button(
            action:action,
            label: {
                content
                    .contentShape(Rectangle())
                    .background(Color.clear)
            }
        )
        .buttonStyle(PlainButtonStyle())
    }
}
