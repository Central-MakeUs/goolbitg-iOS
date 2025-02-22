//
//  ImageHelper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import SwiftUI

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
    
    case back
    
    case homeTab
    case challengeTab
    case buyOrNotTab
    case myPageTab
    
    case bridge
    case myBg
    case appLogoEX
    case greenLogo
    
    case user
    case box
    case headPhone
    case document
    
    case logoStud
    case checkChecked
    case checkEnabled
    case checkDisabled
    case miniChallendar
    case miniAward
    case miniBurn
    case disLikeHand
    case likeHand
    case good
    case bad
    case buyOrNotAdd
    case miniLikeHand
    case miniUnlikeHand
    
    case lock
    case group
    
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
        case .back:
            return UIImage(named: "back") ?? UIImage(resource: .back)
            
        case .homeTab:
            return UIImage(named: "home") ?? UIImage(resource: .home)
        case .challengeTab:
            return UIImage(named: "challenge") ?? UIImage(resource: .challenge)
        case .buyOrNotTab:
            return UIImage(named: "community2") ?? UIImage(resource: .community2)
        case .myPageTab:
            return UIImage(named: "myPage") ?? UIImage(resource: .myPage)
        case .bridge:
            return UIImage(named: "bridge") ?? UIImage(resource: .bridge)
            
        case .myBg:
            return UIImage(named: "myBG") ?? UIImage(resource: .myBg)
        case .appLogoEX:
            return UIImage(named: "appLogoEX") ?? UIImage(resource: .appLogoEX)
            
        case .greenLogo:
            return UIImage(named: "greenLogo") ?? UIImage(resource: .greenLogo)
        case .user:
            return UIImage(named: "User") ?? UIImage(resource: .user)
        case .box:
            return UIImage(named: "box") ?? UIImage(resource: .box)
        case .headPhone:
            return UIImage(named: "headPhone") ?? UIImage(resource: .headPhone)
        case .document:
            return UIImage(named: "document") ?? UIImage(resource: .document)
            
        case .logoStud:
            return UIImage(named: "logoStud") ?? UIImage(resource: .logoStud)
            
        case .checkChecked:
            return UIImage(named: "checkChecked") ?? UIImage(resource: .checkChecked)
        case .checkDisabled:
            return UIImage(named: "checkDisabled") ?? UIImage(resource: .checkDisabled)
        case .checkEnabled:
            return UIImage(named: "checkEnabled") ?? UIImage(resource: .checkEnabled)
            
        case .miniBurn:
            return UIImage(named: "miniBurn") ?? UIImage(resource: .miniBurn)
            
        case .miniAward:
            return UIImage(named: "miniAward") ?? UIImage(resource: .miniAward)
            
        case .miniChallendar:
            return UIImage(named: "miniChallendar") ?? UIImage(resource: .miniChallendar)
        case .disLikeHand:
            return UIImage(named: "disLikeHand") ?? UIImage(resource: .disLikeHand)
            
        case .lock:
            return UIImage(named: "lock") ?? UIImage(resource: .lock)
            
        case .group:
            return UIImage(named: "Group") ?? UIImage(resource: .group)
        case .likeHand:
            return UIImage(named: "likeHand") ?? UIImage(resource: .likeHand)
            
        case .good:
            return UIImage(named: "Good") ?? UIImage(resource: .good)
        case .bad:
            return UIImage(named: "Bad") ?? UIImage(resource: .bad)
            
        case .buyOrNotAdd:
            return UIImage(named: "buyOrNotAdd") ?? UIImage(resource: .buyOrNotAdd)
            
        case .miniLikeHand:
            return UIImage(named: "miniLikeHand") ?? UIImage(resource: .miniLikeHand)
            
        case .miniUnlikeHand:
            return UIImage(named: "miniUnLikeHand") ?? UIImage(resource: .miniUnLikeHand)
        }
    }
    
    var asImage: Image {
        return Image(uiImage: self.image)
    }
    
}

