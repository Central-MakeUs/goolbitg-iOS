//
//  GIFImageView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/17/25.
//

import SwiftUI
import WebKit
import SwiftyGif

struct GIFImageView: UIViewRepresentable {
    
    let imageName: String

    func makeUIView(context: Context) -> UIImageView {
        let image = try? UIImage(gifName: imageName)
        
        guard let image else { return UIImageView() }
        
        let imageView = UIImageView()
        imageView.setGifImage(image)
        
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}
}

