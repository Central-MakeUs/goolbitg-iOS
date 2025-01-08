//
//  PretendardFont.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/8/25.
//

import SwiftUI

enum PretendardFont: String {
    case blackFont = "Pretendard-Black"
    case boldFont = "Pretendard-Bold"
    case extraBold = "Pretendard-ExtraBold"
    case extraLight = "Pretendard-ExtraLight"
    case light = "Pretendard-Light"
    case midFont = "Pretendard-Medium"
    case regularFont = "Pretendard-Regular"
    case semiFont = "Pretendard-SemiBold"
    case thin = "Pretendard-Thin"
    
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
