//
//  ImageCropView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/27/25.
//

import SwiftUI
import PhotosUI

struct CropBox: View {
    @Binding var rect: CGRect
    let minSize: CGSize
    let boxColor: Color

    @State private var initialRect: CGRect? = nil
    @State private var frameSize: CGSize = .zero
    @State private var draggedCorner: UIRectCorner? = nil

    init(
        rect: Binding<CGRect>,
        boxColor: Color,
        minSize: CGSize = .init(width: 100, height: 100)
    ) {
        self._rect = rect
        self.boxColor = boxColor
        self.minSize = minSize
    }

    private var rectDrag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if initialRect == nil {
                    initialRect = rect
                    draggedCorner = closestCorner(point: gesture.startLocation, rect: rect)
                }

                if let draggedCorner {
                    self.rect = dragResize(
                        initialRect: initialRect!,
                        draggedCorner: draggedCorner,
                        frameSize: frameSize,
                        translation: gesture.translation
                    )
                } else {
                    self.rect = drag(
                        initialRect: initialRect!,
                        frameSize: frameSize,
                        translation: gesture.translation
                    )
                }
            }
            .onEnded { gesture in
                initialRect = nil
                draggedCorner = nil
            }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            blur
            box
        }
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear { self.frameSize = geometry.size }
                    .onChange(of: geometry.size) { self.frameSize = $0 }
            }
        }
    }

    private var blur: some View {
        Color.black.opacity(0.5)
            .overlay(alignment: .topLeading) {
                Color.white
                    .frame(width: rect.width - 1, height: rect.height - 1)
                    .offset(x: rect.origin.x, y: rect.origin.y)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .drawingGroup()
            .blendMode(.multiply)
    }

    private var box: some View {
        ZStack {
            pins
        }
        .border(boxColor, width: 2)
        .background(Color.white.opacity(0.001))
        .frame(width: rect.width, height: rect.height)
        .offset(x: rect.origin.x, y: rect.origin.y)
        .gesture(rectDrag)
    }

    private var pins: some View {
        VStack {
            HStack {
                pin(corner: .topLeft)
                Spacer()
                pin(corner: .topRight)
            }
            Spacer()
            HStack {
                pin(corner: .bottomLeft)
                Spacer()
                pin(corner: .bottomRight)
            }
        }
    }

    private func pin(corner: UIRectCorner) -> some View {
        var offX = 1.0
        var offY = 1.0

        switch corner {
        case .topLeft:  offX = -1;  offY = -1
        case .topRight:                 offY = -1
        case .bottomLeft:   offX = -1
        case .bottomRight: break
        default: break
        }

        return Circle()
            .fill(boxColor)
            .frame(width: 16, height: 16)
            .offset(x: offX * 8, y: offY * 8)
    }


    private func closestCorner(point: CGPoint, rect: CGRect, distance: CGFloat = 16) -> UIRectCorner? {
        let ldX = abs(rect.minX.distance(to: point.x)) < distance
        let rdX = abs(rect.maxX.distance(to: point.x)) < distance
        let tdY = abs(rect.minY.distance(to: point.y)) < distance
        let bdY = abs(rect.maxY.distance(to: point.y)) < distance

        guard (ldX || rdX) && (tdY || bdY) else { return nil }

        return if ldX && tdY { .topLeft }
        else if rdX && tdY { .topRight }
        else if ldX && bdY { .bottomLeft }
        else if rdX && bdY { .bottomRight }
        else { nil }
    }
    
    private func dragResize(
        initialRect: CGRect,
        draggedCorner: UIRectCorner,
        frameSize: CGSize,
        translation: CGSize
    ) -> CGRect {
        var offX = 1.0
        var offY = 1.0

        switch draggedCorner {
        case .topLeft:      offX = -1;  offY = -1
        case .topRight:                 offY = -1
        case .bottomLeft:   offX = -1
        case .bottomRight: break
        default: break
        }

        let idealWidth = initialRect.size.width + offX * translation.width
        let idealHeight = initialRect.size.height + offY * translation.height

        // 정사각형 유지: 너비와 높이를 더 작은 값으로 동기화
        let newSize = max(min(idealWidth, idealHeight), minSize.width)

        var newX = initialRect.minX
        var newY = initialRect.minY

        if offX < 0 {
            let sizeChange = newSize - initialRect.width
            newX = max(newX - sizeChange, 0)
        } else {
            newX = min(newX, frameSize.width - newSize)
        }

        if offY < 0 {
            let sizeChange = newSize - initialRect.height
            newY = max(newY - sizeChange, 0)
        } else {
            newY = min(newY, frameSize.height - newSize)
        }

        return .init(origin: .init(x: newX, y: newY), size: .init(width: newSize, height: newSize))
    }


    private func drag(initialRect: CGRect, frameSize: CGSize, translation: CGSize) -> CGRect {
        let maxX = frameSize.width - initialRect.width
        let newX = min(max(initialRect.origin.x + translation.width, 0), maxX)
        let maxY = frameSize.height - initialRect.height
        let newY = min(max(initialRect.origin.y + translation.height, 0), maxY)

        return .init(origin: .init(x: newX, y: newY), size: initialRect.size)
    }
}

struct ImageCropView: View {
    let image: UIImage
    @State var cropArea: CGRect = .init(x: 0, y: 0, width: 100, height: 100)
    @State var imageViewSize: CGSize = .zero
    
    var onCrop: (UIImage?) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                navigationBar
                
                Spacer()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay(alignment: .topLeading) {
                        GeometryReader { geometry in
                            CropBox(rect: $cropArea, boxColor: GBColor.white.asColor)
                                .onAppear {
                                    self.imageViewSize = geometry.size
                                }
                                .onChange(of: geometry.size) {
                                    self.imageViewSize = $0
                                }
                        }
                    }
                
                Spacer()
            }
        }
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

        return UIImage(cgImage: cutImageRef)
    }
}

struct TestView: View {
    
    @State var showPicker = false
    @State var imageItem: PhotosPickerItem?
    @State var showCrop: Bool = false
    @State var image: UIImage = UIImage()
    
    var body: some View {
        VStack {
            Text("TEST")
                .asButton {
                    showPicker.toggle()
                }
        }
        .photosPicker(isPresented: $showPicker, selection: $imageItem)
        .onChange(of: imageItem) { newValue in
            Task {
                guard let imageData = try? await newValue?.loadTransferable(type: Data.self),
                    let image = UIImage(data: imageData) else {
                    return
                }
                await MainActor.run {
                    self.image = image
                }
            }
        }
        .onChange(of: image) { newValue in
            showCrop.toggle()
        }
        .fullScreenCover(isPresented: $showCrop) {
            imageItem = nil
        } content: {
            ImageCropView(
                image: image
            ) { iamge in
                
            }
        }
    }
}
#if DEBUG
@available(iOS 17.0, *)
#Preview {
    VStack {
        TestView()
    }
}
#endif
