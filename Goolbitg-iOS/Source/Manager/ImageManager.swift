//
//  ImageManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import SwiftUI

final class ImageCompressionManager {
    /// 이미지를 지정된 크기 제한 내에서 압축하는 함수
    /// - Parameters:
    ///   - image: 압축할 `UIImage`
    ///   - zipRate: 최대 허용 크기 (MB 단위)
    /// - Returns: 압축된 `Data` 또는 실패 시 `nil`
    func compressImage(_ image: UIImage, zipRate: Double) -> Data? {
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
    }
}

extension ImageCompressionManager: EnvironmentKey {
    static let defaultValue: ImageCompressionManager = ImageCompressionManager()
}

extension EnvironmentValues {
    var imageCompressionManager: ImageCompressionManager {
        get { self[ImageCompressionManager.self] }
        set { self[ImageCompressionManager.self] = newValue }
    }
}
