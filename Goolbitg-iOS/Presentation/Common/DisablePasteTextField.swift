//
//  DisablePasteTextField.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import SwiftUI

struct DisablePasteTextField: View {
    @Binding var text: String
    @Binding var isFocused: Bool
    
    let placeholder: String
    let placeholderColor: Color
    let edge: UIEdgeInsets
    let keyboardType: UIKeyboardType
    let onCommit: (() -> Void)?
    
    var body: some View {
        VStack {
            DisablePasteTextFieldPrepresentable(
                text: $text,
                isFocused: $isFocused,
                keyboardType: keyboardType,
                onCommit: onCommit
            )
            .background(
                HStack {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(placeholderColor)
                        Spacer()
                    }
                }
            )
        }
        .padding(EdgeInsets(top: edge.top, leading: edge.left, bottom: edge.right, trailing: edge.right))
    }
    
}

struct DisablePasteTextFieldPrepresentable: UIViewRepresentable {
    
    @Binding var text: String
    let isFocused: Binding<Bool>
    let keyboardType: UIKeyboardType
    let onCommit: (() -> Void)?
    
    typealias UIViewType = ProtectedTextField
    
    func makeUIView(context: Context) -> ProtectedTextField {
        let textField = ProtectedTextField()
        textField.delegate = context.coordinator
        textField.keyboardType = keyboardType
        
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldTapped), for: .editingDidBegin)
        
        return textField
    }
    
    func updateUIView(_ uiView: ProtectedTextField, context: Context) {
        uiView.text = text
        print(isFocused.wrappedValue, uiView.isFirstResponder )
        if isFocused.wrappedValue, !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        } else if !isFocused.wrappedValue, uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.resignFirstResponder()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isFocused: isFocused, onCommit: onCommit)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool
        
        let onCommit: (() -> Void)?
        
        init(text: Binding<String>, isFocused: Binding<Bool>, onCommit: (() -> Void)?) {
            self._text = text
            self._isFocused = isFocused
            self.onCommit = onCommit
        }

        
        @objc func textFieldTapped() {
            // 사용자가 텍스트 필드를 탭했을 때 포커스를 설정
            if !isFocused {
                isFocused = true
            }
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onCommit?()
            textField.resignFirstResponder()
            return true
        }
    }
}

// Custom TextField with disabling paste action
class ProtectedTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
