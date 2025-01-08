//
//  ImageHelper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import UIKit

enum ImageHelper {
    
    case appLogo
    case appleLogo
    case kakao
    case alertLogo
    case cameraLogo
    case lockLogo
    
    var image: UIImage {
        switch self {
        case .appLogo:
            return UIImage(named: "GBLogo") ?? UIImage(resource: .gbLogo)
        case .appleLogo:
            return UIImage(named: "AppleLogo") ?? UIImage(resource: .appleLogo)
        case .kakao:
            return UIImage(named: "KakaoLogo") ?? UIImage(resource: .kakaoLogo)
            
        case .alertLogo:
            return UIImage(named: "alertLogoV2") ?? UIImage(resource: .alertLogoV2)
        case .cameraLogo:
            return UIImage(named: "cameraLogoV2") ?? UIImage(resource: .cameraLogoV2)
        case .lockLogo:
            return UIImage(named: "imageAuth") ?? UIImage(resource: .imageAuth)
        }
    }
}
