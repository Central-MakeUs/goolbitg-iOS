//
//  AppleFonts.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import SwiftUI

public enum AppleFonts: String {
    
    case apple600 = "AppleSDGothicNeo-SemiBold"
    
    func font(size: CGFloat) -> UIFont {
        let font = UIFont(name: self.rawValue, size: size)
        guard let font else {
            Logger.warning("Font not found: \(self.rawValue)")
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    func asFont(size: CGFloat) -> Font {
        return Font(font(size: size))
    }
}
