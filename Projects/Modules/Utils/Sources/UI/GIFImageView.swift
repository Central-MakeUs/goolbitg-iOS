//
//  GIFImageView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/17/25.
//

import SwiftUI
@preconcurrency import SwiftyGif

public struct GIFImageView: UIViewRepresentable {
    
    public let imageName: String

    public func makeUIView(context: Context) -> UIImageView {
        let image = try? UIImage(gifName: imageName)
        
        guard let image else { return UIImageView() }
        
        let imageView = UIImageView()
        imageView.setGifImage(image)
        
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    public func updateUIView(_ uiView: UIImageView, context: Context) {}
    
    public init(imageName: String) {
        self.imageName = imageName
    }
}

