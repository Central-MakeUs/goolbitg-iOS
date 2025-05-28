//
//  DisablePasteTextField.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import SwiftUI

public struct DisablePasteTextFieldConfiguration {
    public let textColor: Color
    public let placeholder: String
    public let placeholderColor: Color
    public let edge: UIEdgeInsets
    public let keyboardType: UIKeyboardType
    public var isSecureTextEntry: Bool = false
    public var ifLeadingEdge: CGFloat?
    
    public init(
        textColor: Color,
        placeholder: String,
        placeholderColor: Color,
        edge: UIEdgeInsets,
        keyboardType: UIKeyboardType,
        isSecureTextEntry: Bool,
        ifLeadingEdge: CGFloat? = nil
    ) {
        self.textColor = textColor
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor
        self.edge = edge
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecureTextEntry
        self.ifLeadingEdge = ifLeadingEdge
    }
}

public struct DisablePasteTextField: View {
    @Binding var text: String
    var isFocused: Binding<Bool>?
    
    public let placeholder: String
    public let placeholderColor: Color
    public let edge: UIEdgeInsets
    public let keyboardType: UIKeyboardType
    public var isSecureTextEntry: Bool = false
    public var ifLeadingEdge: CGFloat?
    public let onCommit: (() -> Void)?
    public var textColor: Color = .white
    
    public init(
        text: Binding<String>,
        isFocused: Binding<Bool>? = nil,
        placeholder: String,
        placeholderColor: Color,
        isSecureTextEntry: Bool = false,
        edge: UIEdgeInsets,
        keyboardType: UIKeyboardType,
        ifLeadingEdge: CGFloat? = nil,
        onCommit: ( () -> Void)?
    ) {
        self._text = text
        self.isFocused = isFocused
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor
        self.edge = edge
        self.keyboardType = keyboardType
        self.ifLeadingEdge = ifLeadingEdge
        self.isSecureTextEntry = isSecureTextEntry
        self.onCommit = onCommit
    }
    
    public init(
        configuration: DisablePasteTextFieldConfiguration,
        text: Binding<String>,
        isFocused: Binding<Bool>? = nil,
        onCommit: ( () -> Void)?
    ) {
        self._text = text
        self.isFocused = isFocused
        self.placeholder = configuration.placeholder
        self.placeholderColor = configuration.placeholderColor
        self.edge = configuration.edge
        self.keyboardType = configuration.keyboardType
        self.ifLeadingEdge = configuration.ifLeadingEdge
        self.isSecureTextEntry = configuration.isSecureTextEntry
        self.textColor = configuration.textColor
        self.onCommit = onCommit
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            DisablePasteTextFieldPrepresentable(
                text: $text,
                textColor: textColor,
                isFocused: isFocused,
                keyboardType: keyboardType,
                isSecureTextEntry: isSecureTextEntry,
                onCommit: onCommit
            )
            .padding(.leading, ifLeadingEdge ?? 0)
//            .fixedSize(horizontal: true, vertical: false)
        }
        .background(
            HStack {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(placeholderColor)
                    Spacer()
                }
            }
        )
        .padding(EdgeInsets(top: edge.top, leading: edge.left, bottom: edge.right, trailing: edge.right))
    }
    
}

public struct DisablePasteTextFieldPrepresentable: UIViewRepresentable {
    
    @Binding public var text: String
    public var textColor: Color?
    public var isFocused: Binding<Bool>?
    public let keyboardType: UIKeyboardType
    public let isSecureTextEntry: Bool
    public let onCommit: (() -> Void)?
    
    public typealias UIViewType = ProtectedTextField
    
    public func makeUIView(context: Context) -> ProtectedTextField {
        let textField = ProtectedTextField()
        textField.delegate = context.coordinator
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecureTextEntry
        textField.autocorrectionType = .no // 자동 수정 활성화 여부
        textField.autocapitalizationType = .none // 자동 대문자 활성화 여부
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldTapped), for: .editingDidBegin)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        if let textColor {
            textField.textColor = UIColor(textColor)
        }
        return textField
    }
    
    public func updateUIView(_ uiView: ProtectedTextField, context: Context) {
        uiView.text = text
        
        if let isFocused = isFocused {
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
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isFocused: isFocused, onCommit: onCommit)
    }
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        public var isFocused: Binding<Bool>?
        
        public let onCommit: (() -> Void)?
        
        public init(text: Binding<String>, isFocused: Binding<Bool>?, onCommit: (() -> Void)?) {
            self._text = text
            self.isFocused = isFocused
            self.onCommit = onCommit
        }

        
        @objc func textFieldTapped() {
            // 사용자가 텍스트 필드를 탭했을 때 포커스를 설정
            if let isFocused = isFocused, !isFocused.wrappedValue {
                isFocused.wrappedValue = true
            }
        }
        
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onCommit?()
            textField.resignFirstResponder()
            return true
        }
    }
}

// Custom TextField with disabling paste action
public class ProtectedTextField: UITextField {
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    public override func buildMenu(with builder: any UIMenuBuilder) {
        if #available(iOS 17.0, *) {
            builder.remove(menu: .autoFill)
        }
        super.buildMenu(with: builder)
    }
}
