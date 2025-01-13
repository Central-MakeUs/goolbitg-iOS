//
//  EdgeBorder.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/13/25.
//

import SwiftUI

struct EdgeBorder: Shape {
    var width: CGFloat
    var edge: [Edge]
    
    func path(in rect: CGRect) -> Path {
        edge.map { edge -> Path in
            switch edge {
            case .top: return Path(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(CGRect(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(CGRect(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(CGRect(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}
