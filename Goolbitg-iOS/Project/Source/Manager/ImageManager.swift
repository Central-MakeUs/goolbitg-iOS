//
//  ImageManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import SwiftUI
import PhotosUI

@MainActor
final class ImageCompressionManager {
    
    private let allowedExtensions: Set<String> = ["jpeg", "jpg", "png"]
    
    enum ImageManagerError: Error {
        case loadError
        case noAccept
        
        var message: String {
            switch self {
            case .loadError:
                return "이미지 불러오는중 문제가 발생했습니다."
                
            case .noAccept:
                return "지원하지 않는 파일 형식입니다"
            }
        }
    }
    
    
    /// 이미지를 지정된 크기 제한 내에서 비동기 압축하는 함수
    /// - Parameters:
    ///   - image: 압축할 `UIImage`
    ///   - zipRate: 최대 허용 크기 (MB 단위)
    /// - Returns: 압축된 `Data` 또는 실패 시 `nil`
    func compressImageAsync(_ image: UIImage, zipRate: Double) async -> Data? {
        return await Task.detached(priority: .userInitiated) {
            let limitBytes = zipRate * 1024 * 1024  // MB -> Bytes 변환
            Logger.debug("📌 클라이언트가 원하는 크기: \(limitBytes) bytes")
            
            var currentQuality: CGFloat = 1
            var imageData = image.jpegData(compressionQuality: currentQuality)
            
            while let data = imageData,
                  Double(data.count) > limitBytes && currentQuality > 0 {
                Logger.debug("📉 현재 이미지 크기: \(data.count) bytes")
                currentQuality -= 0.1
                imageData = image.jpegData(compressionQuality: currentQuality)
                Logger.debug("⚙️ 현재 압축중인 이미지 크기: \(imageData?.count ?? 0) bytes")
            }
            
            if let data = imageData, Double(data.count) <= limitBytes {
                Logger.debug("✅ 압축 완료: \(data.count) bytes, 최종 압축률: \(currentQuality)")
                return data
            } else {
                Logger.error("❌ 압축 실패: 크기 초과")
                return nil
            }
        }.value
    }

    func checkImageMimeType(item: PhotosPickerItem) async -> Result<UIImage, ImageManagerError> {
        do {
            guard let imageData = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: imageData) else {
                return .failure(.loadError)
            }
            
            guard let uti = item.supportedContentTypes.first?.identifier else  {
                return .failure(.loadError)
            }
            
            let fileExtension = getFileExtension(from: uti)
            
            // ✅ 허용된 확장자인 경우만 저장
            if allowedExtensions.contains(fileExtension) {
                return .success(image)
            }
            // ❌ 허용되지 않은 확장자 -> 무시 (또는 경고 메시지 추가 가능)
            else {
                return .failure(.noAccept)
            }
        } catch {
            return .failure(.loadError)
        }
    }
    
    private func getFileExtension(from uti: String) -> String {
        if uti.contains("jpeg") { return "jpeg" }
        if uti.contains("jpg") { return "jpg" }
        if uti.contains("png") { return "png" }
        return "unknown"
    }
}

extension ImageCompressionManager: @preconcurrency EnvironmentKey {
    static let defaultValue: ImageCompressionManager = ImageCompressionManager()
}

extension EnvironmentValues {
    var imageCompressionManager: ImageCompressionManager {
        get { self[ImageCompressionManager.self] }
        set { self[ImageCompressionManager.self] = newValue }
    }
}
