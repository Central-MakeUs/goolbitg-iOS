//
//  AppleFonts.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import SwiftUI

enum AppleFonts: String {
    
    case apple600 = "600_AppleSDGothicNeo-SemiBold"
    
    func font(size: CGFloat) -> UIFont {
        let font = UIFont(name: self.rawValue, size: size)
        guard let font else {
            print("font 안됨")
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    func asFont(size: CGFloat) -> Font {
        return Font(font(size: size))
    }
}
