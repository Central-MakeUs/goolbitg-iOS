//
//  DisableBackGesture.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import SwiftUI

struct DisableBackGesture: ViewModifier {
    let isGestureDisabled: Bool
    
    func body(content: Content) -> some View {
        content
            .background(BackGestureDisabler(isGestureDisabled: isGestureDisabled))
    }
}

struct BackGestureDisabler: UIViewControllerRepresentable {
    let isGestureDisabled: Bool

    func makeUIViewController(context: Context) -> BackGestureDisablerController {
        let controller = BackGestureDisablerController()
        controller.isGestureDisabled = isGestureDisabled
        return controller
    }

    func updateUIViewController(_ uiViewController: BackGestureDisablerController, context: Context) {
        uiViewController.isGestureDisabled = isGestureDisabled
    }
}

final class BackGestureDisablerController: UIViewController {
    
    var isGestureDisabled: Bool = false {
        didSet {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = !isGestureDisabled
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !isGestureDisabled
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}
