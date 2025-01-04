//
//  GBColor.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import SwiftUI

enum GBColor {
    
    case kakao
    
    var color: UIColor {
        switch self {
        case .kakao:
            return UIColor(hexCode: "#FBE300")
        }
    }
    
}
