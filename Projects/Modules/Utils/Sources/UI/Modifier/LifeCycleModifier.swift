//
//  LifeCycleModifier.swift
//  Utils
//
//  Created by Jae hyung Kim on 5/22/25.
//

import SwiftUI

struct LifeCycleModifier: ViewModifier {
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
