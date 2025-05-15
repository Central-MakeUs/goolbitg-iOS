//
//  LifeCycleModifier.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/8/25.
//

import SwiftUI

extension View {
    func onViewRenderCycle(didLoadAction: @escaping () -> Void,
                           didAppearAction: (() -> Void)? = nil) -> some View {
        modifier(ViewLifeCycleModifier(didLoadAction: didLoadAction,
                                     didAppearAction: didAppearAction))
    }
}

struct ViewLifeCycleModifier: ViewModifier {
    let didLoadAction: () -> Void
    let didAppearAction: (() -> Void)?

    @State
    private var appeared = false

    func body(content: Content) -> some View {
        content.onAppear {
            if !appeared {
                appeared = true
                didLoadAction()
            } else {
                didAppearAction?()
            }
        }
    }
}
