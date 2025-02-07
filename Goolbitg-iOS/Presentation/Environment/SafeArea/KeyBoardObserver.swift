//
//  KeyBoardObserver.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/7/25.
//

import SwiftUI

private struct KeyboardHeightEnvironmentKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    
    var keyboardHeight: CGFloat {
        get { self[KeyboardHeightEnvironmentKey.self] }
        set { self[KeyboardHeightEnvironmentKey.self] = newValue }
    }
}

struct KeyboardHeightEnvironmentValue: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .environment(\.keyboardHeight, keyboardHeight)
            .animation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 0), value: keyboardHeight)
            .background {
                GeometryReader { keyboardProxy in
                    GeometryReader { proxy in
                        Color.clear
                            .onChange(of: keyboardProxy.safeAreaInsets.bottom - proxy.safeAreaInsets.bottom) { newValue in
                                DispatchQueue.main.async {
                                    if keyboardHeight != newValue {
                                        keyboardHeight = newValue
                                    }
                                }
                            }
                    }
                    .ignoresSafeArea(.keyboard)
                }
            }
    }
}

public extension View {
   
    func keyboardHeightEnvironmentValue() -> some View {
        #if os(iOS)
        modifier(KeyboardHeightEnvironmentValue())
        #else
        environment(\.keyboardHeight, 0)
        #endif
    }
}
