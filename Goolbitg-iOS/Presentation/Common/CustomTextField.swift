//
//  CustomTextField.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/10/25.
//

import SwiftUI

struct PlaceholderTextField: View {
    @Binding var text: String
    let placeholder: String
    let placeholderColor: Color
    let edge: UIEdgeInsets
    let onCommit: (() -> Void)?
    
    init(text: Binding<String>,
         placeholder: String,
         placeholderColor: Color,
         edge: UIEdgeInsets = UIEdgeInsets(),
         onCommit: (() -> Void)? = nil)
    {
        self._text = text
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor
        self.edge = edge
        self.onCommit = onCommit
    }
    
    var body: some View {
        TextField("", text: $text, onCommit: {
            onCommit?()
        })
        .background(
            HStack {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(placeholderColor)
                    Spacer()
                }
            }
        )
        .padding(EdgeInsets(top: edge.top, leading: edge.left, bottom: edge.bottom, trailing: edge.right))
    }
}
