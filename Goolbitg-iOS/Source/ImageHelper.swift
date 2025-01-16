//
//  ImageHelper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import UIKit

enum ImageHelper {
    
    case splashBack
    
    case appLogo
    case appLogo2
    
    case appleLogo
    case kakao
    case alertLogo
    case cameraLogo
    case lockLogo
    
    case checked
    case unChecked
    
    case infoTip
    
    case chevronDown
    
    var image: UIImage {
        switch self {
        case .splashBack:
            return UIImage(named: "SplashBack") ?? UIImage(resource: .splashBack)
        case .appLogo:
            return UIImage(named: "Login_AppLogo") ?? UIImage(resource: .loginAppLogo)
        case .appLogo2:
            return UIImage(named: "appLogo2") ?? UIImage(resource: .appLogo2)
        case .appleLogo:
            return UIImage(named: "Apple_Logo") ?? UIImage(resource: .appleLogo)
        case .kakao:
            return UIImage(named: "Kakao_Logo") ?? UIImage(resource: .kakaoLogo)
            
        case .alertLogo:
            return UIImage(named: "alertLogoV2") ?? UIImage(resource: .alertLogoV2)
        case .cameraLogo:
            return UIImage(named: "cameraLogoV2") ?? UIImage(resource: .cameraLogoV2)
        case .lockLogo:
            return UIImage(named: "imageAuth") ?? UIImage(resource: .imageAuth)
        case .checked:
            return UIImage(named: "checked") ?? UIImage(resource: .checked)
        case .unChecked:
            return UIImage(named: "unchecked") ?? UIImage(resource: .unchecked)
            
        case .infoTip:
            return UIImage(named: "infoTip") ?? UIImage(resource: .infoTip)
            
        case .chevronDown:
            return UIImage(named: "chevronDown") ?? UIImage(resource: .chevronDown)
        }
    }
}
