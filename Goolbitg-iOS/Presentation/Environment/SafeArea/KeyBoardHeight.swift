//
//  KeyBoardHeight.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import SwiftUI

/// 키보드 높이를 `@Environment` 로 사용할 수 있도록 하는 환경 변수 키
struct KeyboardHeightEnvironmentKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var keyboardHeightV2: CGFloat {
        get { self[KeyboardHeightEnvironmentKey.self] }
        set { self[KeyboardHeightEnvironmentKey.self] = newValue }
    }
}

struct KeyboardHeightModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .environment(\.keyboardHeightV2, keyboardHeight)
            .subscribeKeyboardHeight { keyBoardHeight in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.keyboardHeight = keyBoardHeight
                }
            }
    }

}

extension View {
    /// 키보드 높이를 `@Environment`로 사용할 수 있도록 하는 modifier
    func trackKeyboardHeight() -> some View {
        self.modifier(KeyboardHeightModifier())
    }
}
