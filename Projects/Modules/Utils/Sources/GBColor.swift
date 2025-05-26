//
//  GBColor.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import SwiftUI

public enum GBColor {
    
    case kakao
    /// 녹색 계열
    case primary900
    case primary800
    case primary700
    case primary600
    case primary500
    case primary400
    case primary300
    case primary200
    case primary100
    case primary50
    
    case main
    case main90
    case main80
    case main70
    case main60
    case main50
    case main40
    case main30
    case main20
    case main15
    case main10
    case main5
    
    /// 회색 계열
    case grey900
    case grey800
    case grey700
    case grey600
    case grey500
    case grey400
    case grey300
    case grey200
    case grey100
    case grey50
    
    /// background
    case background1
    case background2
    
    /// Semantic color
    case warning
    case error
    
    case black
    case white
    
    public var color: UIColor {
        switch self {
        case .kakao:
            return UIColor(hexCode: "#FBE300")
            /// 녹색 계열
        case .primary900:
            return UIColor(hexCode: "#016301")
        case .primary800:
            return UIColor(hexCode: "#268102")
        case .primary700:
            return UIColor(hexCode: "#339213")
        case .primary600:
            return UIColor(hexCode: "#41A420")
        case .primary500:
            return UIColor(hexCode: "#4BB329")
        case .primary400:
            return UIColor(hexCode: "#67BF4E")
        case .primary300:
            return UIColor(hexCode: "#83CA6F")
        case .primary200:
            return UIColor(hexCode: "#A7D899")
        case .primary100:
            return UIColor(hexCode: "#C9E7C1")
        case .primary50:
            return UIColor(hexCode: "#E9F5E6")
            
            /// 회색 계열
        case .grey900:
            return UIColor(hexCode: "#060606")
        case .grey800:
            return UIColor(hexCode: "#161616")
        case .grey700:
            return UIColor(hexCode: "#212121")
        case .grey600:
            return UIColor(hexCode: "#2F2F2F")
        case .grey500:
            return UIColor(hexCode: "#616161")
        case .grey400:
            return UIColor(hexCode: "#464646")
        case .grey300:
            return UIColor(hexCode: "#9E9E9E")
        case .grey200:
            return UIColor(hexCode: "#BDBDBD")
        case .grey100:
            return UIColor(hexCode: "#E0E0E0")
        case .grey50:
            return UIColor(hexCode: "#FAFAFA")
            
            /// 백그라운드
        case .background1:
            return UIColor(hexCode: "#1E1E1E")
        case .background2:
            return UIColor(hexCode: "#FAFAFA")
            
            /// Semantic color
        case .warning:
            return UIColor(hexCode: "#F0BB0D")
        case .error:
            return UIColor(hexCode: "#F05D0D")
            
        case .black:
            return UIColor(hexCode: "#000000")
        case .white:
            return UIColor(hexCode: "#FFFFFF")
            
            
        case .main:
            return UIColor(hexCode: "#4BB329", alpha: 1)
        case .main90:
            return UIColor(hexCode: "#4BB329", alpha: 0.9)
        case .main80:
            return UIColor(hexCode: "#4BB329", alpha: 0.8)
        case .main70:
            return UIColor(hexCode: "#4BB329", alpha: 0.7)
        case .main60:
            return UIColor(hexCode: "#4BB329", alpha: 0.6)
        case .main50:
            return UIColor(hexCode: "#4BB329", alpha: 0.5)
        case .main40:
            return UIColor(hexCode: "#4BB329", alpha: 0.4)
        case .main30:
            return UIColor(hexCode: "#4BB329", alpha: 0.3)
        case .main20:
            return UIColor(hexCode: "#4BB329", alpha: 0.2)
        case .main15:
            return UIColor(hexCode: "#4BB329", alpha: 0.15)
        case .main10:
            return UIColor(hexCode: "#4BB329", alpha: 0.10)
        case .main5:
            return UIColor(hexCode: "#4BB329", alpha: 0.05)
        }
    }
    
    public var asColor: Color {
        return Color(uiColor: color)
    }
    
}
