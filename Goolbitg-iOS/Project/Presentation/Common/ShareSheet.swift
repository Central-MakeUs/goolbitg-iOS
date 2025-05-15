//
//  ShareSheet.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/23/25.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

