//
//  ShareSheet.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/23/25.
//

import SwiftUI

public struct ShareSheet: UIViewControllerRepresentable {
    public let items: [Any]
    
    public init(items: [Any]) {
        self.items = items
    }

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

