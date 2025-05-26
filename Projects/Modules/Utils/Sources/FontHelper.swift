//
//  FontHelper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/10/25.
//

import SwiftUI

public enum FontHelper {
    
    case apple600
    
    case hero1
    case h1
    case h2
    case h3
    case h4
    
    case body1
    case body2
    case body3
    case body4
    case body5
    
    case caption1
    case caption2
    
    case btn1
    case btn2
    case btn3
    case btn4
    
    public var font: Font {
        switch self {
        case .apple600: return AppleFonts.apple600.asFont(size: 15)
            
        case .hero1: return PretendardFont.boldFont.asFont(size: 40)
        case .h1: return PretendardFont.boldFont.asFont(size: 24)
        case .h2: return PretendardFont.midFont.asFont(size: 24)
        case .h3: return PretendardFont.boldFont.asFont(size: 19)
        case .h4: return PretendardFont.boldFont.asFont(size: 16)
            
        case .body1: return PretendardFont.regularFont.asFont(size: 19)
        case .body2: return PretendardFont.semiFont.asFont(size: 16)
        case .body3: return PretendardFont.semiFont.asFont(size: 14)
        case .body4: return PretendardFont.regularFont.asFont(size: 14)
        case .body5: return PretendardFont.regularFont.asFont(size: 12)
            
        case .caption1: return PretendardFont.midFont.asFont(size: 16)
        case .caption2: return PretendardFont.regularFont.asFont(size: 16)
            
        case .btn1: return PretendardFont.boldFont.asFont(size: 19)
        case .btn2: return PretendardFont.boldFont.asFont(size: 16)
        case .btn3: return PretendardFont.midFont.asFont(size: 16)
        case .btn4: return PretendardFont.semiFont.asFont(size: 14)
        }
    }
}
