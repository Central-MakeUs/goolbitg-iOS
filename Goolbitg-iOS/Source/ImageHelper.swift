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
    case plusLogo
    case checkMark2
    
    case warningPop
    case checkPop
    case right
    
    case greenCard
    case logo3
    case homeBack
    case bell
    case won
    case trophy
    
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
            
        case .plusLogo:
            return UIImage(named: "plusLogo") ?? UIImage(resource: .plusLogo)
        case .checkMark2:
            return UIImage(named: "CheckBox2") ?? UIImage(resource: .checkBox2)
            
        case .warningPop:
            return UIImage(named: "warningPop") ?? UIImage(resource: .warningPop)
            
        case .checkPop:
            return UIImage(named: "CheckPopup") ?? UIImage(resource: .checkPopup)
        case .right:
            return UIImage(named: "rightCh") ?? UIImage(resource: .rightCh)
        case .greenCard:
            return UIImage(named: "greenCard") ?? UIImage(resource: .greenCard)
        case .logo3:
            return UIImage(named: "Logo3") ?? UIImage(resource: .logo3)
        case .homeBack:
            return UIImage(named: "homeBack") ?? UIImage(resource: .homeBack)
        case .bell:
            return UIImage(named: "bell") ?? UIImage(resource: .bell)
        case .won:
            return UIImage(named: "Won") ?? UIImage(resource: .trophy)
        case .trophy:
            return UIImage(named: "Trophy") ?? UIImage(resource: .won)
        }
    }
}
