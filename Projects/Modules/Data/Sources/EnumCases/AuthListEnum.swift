//
//  AuthListEnum.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/5/25.
//

import Foundation
import Utils

public enum AuthListEnum: CaseIterable, Equatable {
    case alert
    case camera
    case image
    
    public var title: String {
        switch self {
        case .alert:
            return TextHelper.authAlertAccess
        case .camera:
            return TextHelper.authCameraAccess
        case .image:
            return TextHelper.authAlbumAccess
        }
    }
    
    public var subTitle: String {
        switch self {
        case .alert:
            return TextHelper.authAlertAccessSub
        case .camera:
            return TextHelper.authCameraAccessSub
        case .image:
            return TextHelper.authAlbumAccessSub
        }
    }
    
    public var image: ImageHelper {
        switch self {
        case .alert:
            return ImageHelper.alertLogo
        case .camera:
            return ImageHelper.cameraLogo
        case .image:
            return ImageHelper.lockLogo
        }
    }
}
