//
//  CropBoxView.swift
//  FeatureCommon
//
//  Created by Jae hyung Kim on 5/23/25.
//

import SwiftUI

public struct CropBoxView: View {
    @Binding public var rect: CGRect
    public let minSize: CGSize
    public let boxColor: Color

    @State private var initialRect: CGRect? = nil
    @State private var frameSize: CGSize = .zero
    @State private var draggedCorner: UIRectCorner? = nil

    public init(
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

    public var body: some View {
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
