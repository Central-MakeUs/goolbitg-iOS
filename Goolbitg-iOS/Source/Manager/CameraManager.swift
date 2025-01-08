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
    func requestAuth() async -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
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
