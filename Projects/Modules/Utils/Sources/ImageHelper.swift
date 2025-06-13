//
//  ImageHelper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import SwiftUI
import Kingfisher

public enum ImageHelper {
    
    case splashBack
    
    case appLogo
    case appLogo2
    
    case appleLogo
    case kakao
    
    case alertTriangle
    case alertLogo
    case cameraLogo
    case lockLogo
    
    case checked
    case unChecked
    
    case infoTip
    
    case chevronDown
    case plusLogo
    case checkMark2
    
    case warning
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
    
    // MARK: Push Alert Part
    case pushNull
    case pushVote
    case pushChatting
    case pushChallenge
    
    
    case loginAppLogo
    case xSmall
    
    case secretRoomLogo
    case group
    case settingBtn
    
    public var image: UIImage {
        switch self {
        case .splashBack:
//            return UIImage(named: "SplashBack") ?? UIImage(resource: .splashBack)
            return UtilsAsset.splashBack.image
        case .appLogo:
//            return UIImage(named: "Login_AppLogo") ?? UIImage(resource: .loginAppLogo)
            return UtilsAsset.loginAppLogo.image
        case .appLogo2:
//            return UIImage(named: "appLogo2") ?? UIImage(resource: .appLogo2)
            return UtilsAsset.appLogo2.image
        case .appleLogo:
//            return UIImage(named: "Apple_Logo") ?? UIImage(resource: .appleLogo)
            return UtilsAsset.appleLogo.image
        case .kakao:
//            return UIImage(named: "Kakao_Logo") ?? UIImage(resource: .kakaoLogo)
            return UtilsAsset.kakaoLogo.image
        case .alertLogo:
//            return UIImage(named: "alertLogoV2") ?? UIImage(resource: .alertLogoV2)
            return UtilsAsset.alertLogoV2.image
        case .cameraLogo:
//            return UIImage(named: "cameraLogoV2") ?? UIImage(resource: .cameraLogoV2)
            return UtilsAsset.cameraLogoV2.image
        case .lockLogo:
//            return UIImage(named: "imageAuth") ?? UIImage(resource: .imageAuth)
            return UtilsAsset.imageAuth.image
        case .checked:
//            return UIImage(named: "checked") ?? UIImage(resource: .checked)
            return UtilsAsset.checked.image
        case .unChecked:
//            return UIImage(named: "unchecked") ?? UIImage(resource: .unchecked)
            return UtilsAsset.unchecked.image
        case .infoTip:
//            return UIImage(named: "infoTip") ?? UIImage(resource: .infoTip)
            return UtilsAsset.infoTip.image
        case .chevronDown:
//            return UIImage(named: "chevronDown") ?? UIImage(resource: .chevronDown)
            return UtilsAsset.chevronDown.image
        case .plusLogo:
//            return UIImage(named: "plusLogo") ?? UIImage(resource: .plusLogo)
            return UtilsAsset.plusLogo.image
        case .checkMark2:
//            return UIImage(named: "CheckBox2") ?? UIImage(resource: .checkBox2)
            return UtilsAsset.checkBox2.image
        case .warningPop:
//            return UIImage(named: "warningPop") ?? UIImage(resource: .warningPop)
            return UtilsAsset.warningPop.image
        case .checkPop:
//            return UIImage(named: "CheckPopup") ?? UIImage(resource: .checkPopup)
            return UtilsAsset.checkPopup.image
        case .right:
//            return UIImage(named: "rightCh") ?? UIImage(resource: .rightCh)
            return UtilsAsset.rightCh.image
        case .greenCard:
//            return UIImage(named: "greenCard") ?? UIImage(resource: .greenCard)
            return UtilsAsset.greenCard.image
        case .logo3:
//            return UIImage(named: "Logo3") ?? UIImage(resource: .logo3)
            return UtilsAsset.logo3.image
        case .homeBack:
//            return UIImage(named: "homeBack") ?? UIImage(resource: .homeBack)
            return UtilsAsset.homeBack.image
        case .bell:
//            return UIImage(named: "bell") ?? UIImage(resource: .bell)
            return UtilsAsset.bell.image
        case .won:
//            return UIImage(named: "Won") ?? UIImage(resource: .trophy)
            return UtilsAsset.won.image
        case .trophy:
//            return UIImage(named: "Trophy") ?? UIImage(resource: .won)
            return UtilsAsset.trophy.image
        case .back:
//            return UIImage(named: "back") ?? UIImage(resource: .back)
            return UtilsAsset.back.image
        case .homeTab:
//            return UIImage(named: "home") ?? UIImage(resource: .home)
            return UtilsAsset.home.image
        case .challengeTab:
//            return UIImage(named: "challenge") ?? UIImage(resource: .challenge)
            return UtilsAsset.challenge.image
        case .buyOrNotTab:
//            return UIImage(named: "community2") ?? UIImage(resource: .community2)
            return UtilsAsset.community2.image
        case .myPageTab:
//            return UIImage(named: "myPage") ?? UIImage(resource: .myPage)
            return UtilsAsset.myPage.image
        case .bridge:
//            return UIImage(named: "bridge") ?? UIImage(resource: .bridge)
            return UtilsAsset.bridge.image
        case .myBg:
//            return UIImage(named: "myBG") ?? UIImage(resource: .myBg)
            return UtilsAsset.myBg.image
        case .appLogoEX:
//            return UIImage(named: "appLogoEX") ?? UIImage(resource: .appLogoEX)
            return UtilsAsset.appLogoEX.image
        case .greenLogo:
//            return UIImage(named: "greenLogo") ?? UIImage(resource: .greenLogo)
            return UtilsAsset.greenLogo.image
        case .user:
//            return UIImage(named: "User") ?? UIImage(resource: .user)
            return UtilsAsset.user.image
        case .box:
//            return UIImage(named: "box") ?? UIImage(resource: .box)
            return UtilsAsset.box.image
        case .headPhone:
//            return UIImage(named: "headPhone") ?? UIImage(resource: .headPhone)
            return UtilsAsset.headPhone.image
        case .document:
//            return UIImage(named: "document") ?? UIImage(resource: .document)
            return UtilsAsset.document.image
        case .logoStud:
//            return UIImage(named: "logoStud") ?? UIImage(resource: .logoStud)
            return UtilsAsset.logoStud.image
        case .checkChecked:
//            return UIImage(named: "checkChecked") ?? UIImage(resource: .checkChecked)
            return UtilsAsset.checkChecked.image
        case .checkDisabled:
//            return UIImage(named: "checkDisabled") ?? UIImage(resource: .checkDisabled)
            return UtilsAsset.checkDisabled.image
        case .checkEnabled:
//            return UIImage(named: "checkEnabled") ?? UIImage(resource: .checkEnabled)
            return UtilsAsset.checkEnabled.image
        case .miniBurn:
//            return UIImage(named: "miniBurn") ?? UIImage(resource: .miniBurn)
            return UtilsAsset.miniBurn.image
        case .miniAward:
//            return UIImage(named: "miniAward") ?? UIImage(resource: .miniAward)
            return UtilsAsset.miniAward.image
        case .miniChallendar:
//            return UIImage(named: "miniChallendar") ?? UIImage(resource: .miniChallendar)
            return UtilsAsset.miniChallendar.image
        case .disLikeHand:
//            return UIImage(named: "disLikeHand") ?? UIImage(resource: .disLikeHand)
            return UtilsAsset.disLikeHand.image
        case .likeHand:
//            return UIImage(named: "likeHand") ?? UIImage(resource: .likeHand)
            return UtilsAsset.likeHand.image
        case .good:
//            return UIImage(named: "Good") ?? UIImage(resource: .good)
            return UtilsAsset.good.image
        case .bad:
//            return UIImage(named: "Bad") ?? UIImage(resource: .bad)
            return UtilsAsset.bad.image
        case .buyOrNotAdd:
//            return UIImage(named: "buyOrNotAdd") ?? UIImage(resource: .buyOrNotAdd)
            return UtilsAsset.buyOrNotAdd.image
        case .miniLikeHand:
//            return UIImage(named: "miniLikeHand") ?? UIImage(resource: .miniLikeHand)
            return UtilsAsset.miniLikeHand.image
        case .miniUnlikeHand:
//            return UIImage(named: "miniUnLikeHand") ?? UIImage(resource: .miniUnLikeHand)
            return UtilsAsset.miniUnLikeHand.image
        // MARK: 푸시 알림 이미지
            
        case .pushNull:
//            return UIImage(named: "PushNull") ?? UIImage(resource: .pushNull)
            return UtilsAsset.pushNull.image
        case .pushVote:
//            return UIImage(named: "PushVote") ?? UIImage(resource: .pushVote)
            return UtilsAsset.pushVote.image
        case .pushChatting:
//            return UIImage(named: "PushChatting") ?? UIImage(resource: .pushChatting)
            return UtilsAsset.pushChatting.image
        case .pushChallenge:
//            return UIImage(named: "PushChallenge") ?? UIImage(resource: .pushChallenge)
            return UtilsAsset.pushChallenge.image
            
        case .warning:
            return UtilsAsset.warning.image
            
        case .alertTriangle:
            return UtilsAsset.alertTriangle.image
            
        case .loginAppLogo:
            return UtilsAsset.loginAppLogo.image
            
        case .xSmall:
            return UtilsAsset.xSmall.image
            
        case .secretRoomLogo:
            return UtilsAsset.secretRoom.image
            
        case .group:
            return UtilsAsset.group.image
            
        case .settingBtn:
            return UtilsAsset.settingBtn.image
        }
    }
    
    public var asImage: Image {
        return Image(uiImage: self.image)
    }
    
    
    public static func downLoadImage(url: URL) async throws -> UIImage {
        let result = try await KingfisherManager.shared.retrieveImage(with: url)
        return result.image
    }
}

