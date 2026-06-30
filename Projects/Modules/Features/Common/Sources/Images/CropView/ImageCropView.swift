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
        VStack(spacing: 0) {
            navigationBar
                .padding(.bottom, 14)
                .padding(.top, safeAreaInsets.top)

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipped()
                .overlay(alignment: .topLeading) {
                    GeometryReader { geometry in
                        CropBoxView(rect: $cropArea, boxColor: GBColor.white.asColor)
                            .onAppear {
                                updateImageViewSize(geometry.size)
                            }
                            .onChange(of: geometry.size) {
                                updateImageViewSize($0)
                            }
                    }
                }

            Spacer()
        }
        .background(GBColor.background1.asColor.ignoresSafeArea())
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
        guard imageViewSize.width > 0,
              imageViewSize.height > 0 else {
            return image.fixedOrientation()
        }

        let normalizedImage = image.fixedOrientation()
        guard let cgImage = normalizedImage.cgImage else {
            return normalizedImage
        }

        let imageBounds = CGRect(
            x: 0,
            y: 0,
            width: CGFloat(cgImage.width),
            height: CGFloat(cgImage.height)
        )
        let scaleX = imageBounds.width / imageViewSize.width
        let scaleY = imageBounds.height / imageViewSize.height
        let scaledCropArea = CGRect(
            x: cropArea.origin.x * scaleX,
            y: cropArea.origin.y * scaleY,
            width: cropArea.size.width * scaleX,
            height: cropArea.size.height * scaleY
        ).integral
        let boundedCropArea = scaledCropArea.intersection(imageBounds)
        
        guard !boundedCropArea.isNull,
              !boundedCropArea.isEmpty,
              let cutImageRef = cgImage.cropping(to: boundedCropArea) else {
            return normalizedImage
        }
        
        let croppedImage = UIImage(cgImage: cutImageRef, scale: normalizedImage.scale, orientation: .up)
        
        return croppedImage
    }

    private func updateImageViewSize(_ size: CGSize) {
        imageViewSize = size
        cropArea = cropArea.constrained(to: size, minSize: 100)
    }
}

private extension CGRect {
    func constrained(to frameSize: CGSize, minSize: CGFloat) -> CGRect {
        guard frameSize.width > 0,
              frameSize.height > 0 else {
            return self
        }

        let maxSize = max(1, min(frameSize.width, frameSize.height))
        let side = min(max(width, min(minSize, maxSize)), maxSize)
        let maxX = max(0, frameSize.width - side)
        let maxY = max(0, frameSize.height - side)
        let x = min(max(origin.x, 0), maxX)
        let y = min(max(origin.y, 0), maxY)

        return CGRect(x: x, y: y, width: side, height: side)
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
