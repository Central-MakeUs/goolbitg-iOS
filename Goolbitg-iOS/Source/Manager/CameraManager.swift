//
//  CameraManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/8/25.
//

import AVFoundation
import ComposableArchitecture

final class CameraManager: Sendable {
    /// 카메라 권한 요청
    /// - Returns: 요청결과
    @discardableResult
    func requestAuth() async -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
    }
    
    /// 카메라 권환 확인
    /// - Returns: 결과
    func isAuthorized() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
}

extension CameraManager: DependencyKey {
    static let liveValue: CameraManager = CameraManager()
}

extension DependencyValues {
    var cameraManager: CameraManager {
        get { self[CameraManager.self] }
        set { self[CameraManager.self] = newValue }
    }
}
