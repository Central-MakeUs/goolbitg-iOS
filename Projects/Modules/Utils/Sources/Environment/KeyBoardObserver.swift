//
//  KeyBoardObserver.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/7/25.
//

import SwiftUI

extension EnvironmentValues {
    var keyboardHeight: CGFloat {
        get { self[KeyboardHeightEnvironmentKey.self] }
        set { self[KeyboardHeightEnvironmentKey.self] = newValue }
    }
}

public struct KeyboardHeightEnvironmentValue: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0 {
        didSet {
            print("\(keyboardHeight)")
        }
    }
    
    var ifNeedMoreHeight: CGFloat
    
    public init(ifNeedMoreHeight: CGFloat = 0) {
        self.ifNeedMoreHeight = ifNeedMoreHeight
    }
    
    public func body(content: Content) -> some View {
        let totalHeight = self.keyboardHeight + self.ifNeedMoreHeight
        return content
            .environment(\.keyboardHeight, totalHeight)
            .animation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 0), value: totalHeight)
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

extension View {
   
    public func keyboardHeightEnvironmentValue(ifNeedMoreHeight: CGFloat = 0) -> some View {
        #if os(iOS)
        modifier(KeyboardHeightEnvironmentValue(ifNeedMoreHeight: ifNeedMoreHeight))
        #else
        environment(\.keyboardHeight, 0)
        #endif
    }
}
