//
//  AlbumAuthManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/8/25.
//

import Photos
import ComposableArchitecture

final class AlbumAuthManager: Sendable {
    
    func requestAlbumPermission() async -> AlbumAuthCase {
        let result = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        switch result {
        case .notDetermined: // 앱 최초
            return .noOnce
        case .restricted: // 조직적 거부
            return .denied
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .limited: // 특정 사진
            return .limitAuthorized
        @unknown default:
            return .denied
        }
    }
}

extension AlbumAuthManager: DependencyKey {
    static let liveValue: AlbumAuthManager = AlbumAuthManager()
}

extension DependencyValues {
    var albumAuthManager: AlbumAuthManager {
        get { self[AlbumAuthManager.self] }
        set { self[AlbumAuthManager.self] = newValue }
    }
}
