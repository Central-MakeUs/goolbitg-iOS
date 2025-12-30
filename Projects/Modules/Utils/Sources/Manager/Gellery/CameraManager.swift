//
//  CameraManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/8/25.
//

import AVFoundation
import ComposableArchitecture

public final class CameraManager: @unchecked Sendable {
    
    // 전체 적용되는 세션
    public var session: AVCaptureSession?
    public var delegate: AVCapturePhotoCaptureDelegate?
    
    // 카메라 출력
    public let output = AVCapturePhotoOutput()
    public let previewLayer = AVCaptureVideoPreviewLayer()
    
    // 현재 사용 중인 카메라 방향
    public var currentCameraPosition: AVCaptureDevice.Position = .back
    
    /// 카메라 권한 요청
    /// - Returns: 요청결과
    @discardableResult
    public func requestAuth() async -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
    }
    
    /// 카메라 권환 확인
    /// - Returns: 결과
    public func isAuthorized() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    // 실행 시 권한 확인 및 카메라 세팅
    @MainActor
    public func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> Void) {
        self.delegate = delegate
        checkPermission(completion: completion)
    }
    
    @MainActor
    private func checkPermission(completion: @escaping (Error?) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.setupCamera(completion: completion)
                }
            }
        case .restricted, .denied:
            completion(NSError(domain: "CameraManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "카메라 접근이 제한되었습니다."]))
        case .authorized:
            setupCamera(completion: completion)
        @unknown default:
            completion(NSError(domain: "CameraManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "알 수 없는 오류"]))
        }
    }
    
    // 카메라 설정
    private func setupCamera(completion: @escaping (Error?) -> Void) {
        let session = AVCaptureSession()
        
        do {
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition)
            guard let camera = device else {
                throw NSError(domain: "CameraService", code: 3, userInfo: [NSLocalizedDescriptionKey: "카메라를 찾을 수 없습니다."])
            }
            
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.session = session
            
            session.startRunning()
            self.session = session
            
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    /// 사진 촬영 (여러 장 가능)
    public func capturePhoto(count: Int = 1, settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        guard let delegate = delegate else { return }
        
        for _ in 0..<count {
            output.capturePhoto(with: settings, delegate: delegate)
        }
    }
    
    /// 카메라 전후면 전환
    public func toggleCamera(completion: @escaping (Error?) -> Void) {
        guard let session = session else { return }
        
        session.beginConfiguration()
        
        // 기존 입력 제거
        if let currentInput = session.inputs.first as? AVCaptureDeviceInput {
            session.removeInput(currentInput)
        }
        
        // 새로운 카메라 설정
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        do {
            let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition)
            guard let camera = newDevice else {
                throw NSError(domain: "CameraService", code: 4, userInfo: [NSLocalizedDescriptionKey: "카메라 전환 실패"])
            }
            
            let newInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
            }
            
            session.commitConfiguration()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
}

extension CameraManager: DependencyKey {
    public static let liveValue: CameraManager = CameraManager()
}

extension DependencyValues {
    public var cameraManager: CameraManager {
        get { self[CameraManager.self] }
        set { self[CameraManager.self] = newValue }
    }
}
