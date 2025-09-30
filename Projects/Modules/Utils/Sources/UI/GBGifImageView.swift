//
//  GBGifImageView.swift
//  Utils
//
//  Created by Jae hyung Kim on 9/30/25.
//

import SwiftUI
import Foundation
#if canImport(SwiftyGif) // 마이그레이션 전
    @preconcurrency import SwiftyGif
#endif
import Gifu

/// 모듈(프레임워크) 번들에서 GIF를 안전하게 로드하여 표시하는 UIViewRepresentable 래퍼
public struct GBGifImageView: UIViewRepresentable {
    
    /// 로드할 GIF 파일명 (확장자 포함/미포함 모두 허용: 예)
    public let imageName: String
    
    public var contentMode: UIView.ContentMode
    
    private let preferredBundle: Bundle?
    
    public func makeUIView(context: Context) -> UIImageView {
#if canImport(SwiftyGif)
        swiftyVersion()
#else
        gifVersion()
#endif
    }

    public func updateUIView(_ uiView: UIImageView, context: Context) {}
    
    public init(
        imageName: String,
        contentMode: UIView.ContentMode,
        preferredBundle: Bundle? = nil
    ) {
        self.imageName = imageName
        self.contentMode = contentMode
        self.preferredBundle = preferredBundle
    }
    
    /// 주어진 파일명을 바탕으로 모듈 번들에서 GIF를 찾아 UIImage로 반환합니다.
    /// - 이름에 확장자가 포함되어 있지 않으면 기본적으로 ".gif"를 가정합니다.
    /// - 탐색 우선순위: 호출자 번들 → Utils 번들 → 메인 번들
    /// - Parameter name: gif 이미지 이름
    /// - Returns: Data (Optional)
    private func loadGIF(named name: String) -> Data? {
        let (base, ext) = splitNameAndExtension(from: name)
        // 탐색 우선순위: 호출자 번들 → Utils 번들 → 메인 번들
        let bundles: [Bundle] = [
            preferredBundle,
            resourceBundle,
            .main
        ].compactMap { $0 }

        for b in bundles {
            if let url = b.url(forResource: name, withExtension: nil)
                ?? b.url(forResource: base, withExtension: ext),
               let data = try? Data(contentsOf: url) {
                return data
            }
        }
        return nil
    }

    /*
     리소스를 로드할 번들 결정
     - SPM 환경: Bundle.module 사용 (패키지 리소스 번들)
     - 프레임워크/라이브러리: Bundle(for:) 사용 (해당 모듈의 번들)
    */
    #if SWIFT_PACKAGE
    private var resourceBundle: Bundle { .module }
    #else
    private var resourceBundle: Bundle { Bundle(for: BundleToken.self) }
    /// 이 타입이 포함된 번들을 식별하기 위한 토큰 클래스 (실제 로직 없음)
    private final class BundleToken {}
    #endif

    /// 파일명에서 기본 이름과 확장자를 분리합니다. 확장자가 없으면 "gif"를 기본값으로 사용합니다.
    private func splitNameAndExtension(from name: String) -> (String, String) {
        let ns = name as NSString
        let ext = ns.pathExtension.isEmpty ? "gif" : ns.pathExtension
        let base = ns.deletingPathExtension
        return (base, ext)
    }
    
    /// 디버그 빌드에서만 로깅하여 어떤 번들에서 탐색 중인지 확인
    private func findBundleName() {
        #if DEBUG
        let bundleDesc: String
        #if SWIFT_PACKAGE
        bundleDesc = "Bundle.module"
        #else
        bundleDesc = String(describing: resourceBundle.bundlePath)
        #endif
        print("GBGIFImageView: Can't find GIF named \(imageName) in bundle: \(bundleDesc)")
        #endif
    }
}

// MARK: SwiftyGIF
#if canImport(SwiftyGif)
extension GBGifImageView {
    
    private func swiftyVersion() -> UIImageView {
        let imageView = UIImageView()
        
        imageView.contentMode = contentMode

        // 모듈 번들에서 GIF를 찾아 로드
        if let gifImageData = loadGIF(named: imageName),
           let gifImage = try? UIImage(gifData: gifImageData) {
            imageView.setGifImage(gifImage)
        } else {
            findBundleName()
        }

        return imageView
    }
}
#endif

// MARK: GIF
extension GBGifImageView {
    
    private func gifVersion() -> UIImageView {
        print("Gifu")
        let imageView = GIFImageView()
        
        imageView.contentMode = contentMode
        
        if let gifImageData = loadGIF(named: imageName) {
            imageView.animate(withGIFData: gifImageData)
        } else {
            findBundleName()
        }
        
        return imageView
    }
}
