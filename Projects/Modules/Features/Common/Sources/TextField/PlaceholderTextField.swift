//
//  PlaceholderTextField.swift
//  FeatureCommon
//
//  Created by Jae hyung Kim on 5/23/25.
//

import SwiftUI

public struct PlaceholderTextField: View {
    @Binding public var text: String
    public let placeholder: String
    public let placeholderColor: Color
    public let edge: UIEdgeInsets
    public let onCommit: (() -> Void)?
    
    public init(text: Binding<String>, placeholder: String, placeholderColor: Color, edge: UIEdgeInsets, onCommit: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor
        self.edge = edge
        self.onCommit = onCommit
    }
    
    public var body: some View {
        TextField("", text: $text, onCommit: {
            onCommit?()
        })
        .background(
            HStack {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(placeholderColor)
                    Spacer()
                }
            }
        )
        .padding(EdgeInsets(top: edge.top, leading: edge.left, bottom: edge.bottom, trailing: edge.right))
    }
}
