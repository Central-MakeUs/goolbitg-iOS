//
//  ImageCropView.swift
//  FeatureCommon
//
//  Created by Jae hyung Kim on 5/23/25.
//

import SwiftUI
import Utils

public struct ImageCropView: View {
    public let image: UIImage
    @State public var cropArea: CGRect = .init(x: 0, y: 0, width: 100, height: 100)
    @State public var imageViewSize: CGSize = .zero
    
    public var onCrop: (UIImage?) -> Void
    
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    public init(image: UIImage, onCrop: @escaping (UIImage?) -> Void) {
        self.image = image
        self.onCrop = onCrop
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            navigationBar
                .padding(.top, safeAreaInsets.top)
                .padding(.bottom, 14)
            
            VStack(spacing: 0) {
                navigationBar
                    .padding(.top, safeAreaInsets.top)
                    .hidden()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .overlay(alignment: .topLeading) {
                        GeometryReader { geometry in
                            CropBoxView(rect: $cropArea, boxColor: GBColor.white.asColor)
                                .onAppear {
                                    imageViewSize = geometry.size
                                }
                                .onChange(of: geometry.size) {
                                    imageViewSize = $0
                                }
                        }
                    }
                
                Spacer()
                Color.clear
                    .frame(height: safeAreaInsets.bottom)
            }
        }
        .background(GBColor.background1.asColor)
    }
    
    private var navigationBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(uiImage: ImageHelper.back.image)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .asButton {
                        onCrop(nil)
                    }
                
                Spacer()
                
                Text("사진 편집")
                    .font(FontHelper.h3.font)
                    .foregroundStyle(GBColor.white.asColor)
                
                Spacer()
                
                Text("완료")
                    .font(FontHelper.h3.font)
                    .foregroundStyle(GBColor.main.asColor)
                    .asButton {
                        onCrop(self.crop(image: image, cropArea: cropArea, imageViewSize: imageViewSize))
                    }
            }
            .padding(.horizontal, SpacingHelper.md.pixel)
            .padding(.vertical, 16)
        }
        .background(GBColor.background1.asColor)
    }
    
    private func crop(image: UIImage, cropArea: CGRect, imageViewSize: CGSize) -> UIImage? {
        let scaleX = image.size.width / imageViewSize.width * image.scale
        let scaleY = image.size.height / imageViewSize.height * image.scale
        let scaledCropArea = CGRect(
            x: cropArea.origin.x * scaleX,
            y: cropArea.origin.y * scaleY,
            width: cropArea.size.width * scaleX,
            height: cropArea.size.height * scaleY
        )
        
        guard let cutImageRef: CGImage = image.cgImage?.cropping(to: scaledCropArea) else {
            return nil
        }
        
        let croppedImage = UIImage(cgImage: cutImageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return croppedImage.fixedOrientation()
    }
}

extension UIImage {
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
