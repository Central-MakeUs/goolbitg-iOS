//
//  FlowLayout.swift
//  FeatureCommon
//
//  Created by Jae hyung Kim on 7/10/25.
//

import SwiftUI

public struct FlowLayout: Layout {
    var spacing: CGFloat? = nil
    var lineSpacing: CGFloat = 10.0
    
    public struct Cache {
        var sizes: [CGSize] = []
        var spacing: [CGFloat] = []
    }
    
    public func makeCache(subviews: Subviews) -> Cache {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let spacing: [CGFloat] = subviews.indices.map { index in
            guard index != subviews.count - 1 else {
                return 0
            }
            
            return subviews[index].spacing.distance(
                to: subviews[index+1].spacing,
                along: .horizontal
            )
        }
        
        return Cache(sizes: sizes, spacing: spacing)
    }
    
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        var totalHeight = 0.0
        var lineWidth = 0.0
        var lineHeight = 0.0
        
        let availableWidth = proposal.width ?? .infinity
        
        for index in subviews.indices {
            let itemWidth = cache.sizes[index].width
            if lineWidth + itemWidth > availableWidth {
                totalHeight += lineHeight + lineSpacing
                lineWidth = itemWidth + (spacing ?? cache.spacing[index])
                lineHeight = cache.sizes[index].height
            } else {
                lineWidth += itemWidth + (spacing ?? cache.spacing[index])
                lineHeight = max(lineHeight, cache.sizes[index].height)
            }
        }
        
        totalHeight += lineHeight
        
        return CGSize(width: availableWidth, height: totalHeight)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0
        let epsilon: CGFloat = 0.5 // 오차 허용치

        for index in subviews.indices {
            let itemWidth = cache.sizes[index].width
            let nextItemRightEdge = lineX + itemWidth

            if nextItemRightEdge > bounds.maxX + epsilon {
                lineY += lineHeight + lineSpacing
                lineHeight = 0
                lineX = bounds.minX
            }

            let position = CGPoint(x: lineX, y: lineY)

            lineHeight = max(lineHeight, cache.sizes[index].height)
            lineX += itemWidth + (spacing ?? cache.spacing[index])

            subviews[index].place(
                at: position,
                anchor: .topLeading,
                proposal: ProposedViewSize(cache.sizes[index])
            )
        }
    }

}
