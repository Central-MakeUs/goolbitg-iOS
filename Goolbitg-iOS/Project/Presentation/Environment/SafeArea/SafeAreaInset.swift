//
//  SafeAreaInset.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import SwiftUI

@MainActor
private struct SafeAreaInsetsKey: @preconcurrency EnvironmentKey {
    static var defaultValue: EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
