//
//  AlbumAuthManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/8/25.
//

import Photos
import ComposableArchitecture

public enum AlbumAuthCase {
    case noOnce
    case authorized
    case denied
    case limitAuthorized
}

public final class AlbumAuthManager: Sendable {
    
    /// 앨범 권한을 요청합니다.
    /// - Returns: 요청결과
    @discardableResult
    public func requestAlbumPermission() async -> AlbumAuthCase {
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
    
    /// 현재 앨범 권한 상태를 확인합니다.
    /// - Returns: 앨범 권한 상태
    public func currentAlbumPermission() -> AlbumAuthCase {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            return .noOnce
        case .restricted:
            return .denied
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .limited:
            return .limitAuthorized
        @unknown default:
            return .denied
        }
    }
}

extension AlbumAuthManager: DependencyKey {
    public static let liveValue: AlbumAuthManager = AlbumAuthManager()
}

extension DependencyValues {
    public var albumAuthManager: AlbumAuthManager {
        get { self[AlbumAuthManager.self] }
        set { self[AlbumAuthManager.self] = newValue }
    }
}
