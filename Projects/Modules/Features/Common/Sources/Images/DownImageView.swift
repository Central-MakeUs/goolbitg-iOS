//
//  DownImageView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import SwiftUI
import Kingfisher
import Utils

public struct DownImageView: View {

    public let url: URL?
    public let option: Option
    public var fallbackURL: URL? = nil
    public var fallBackImg: UIImage? = nil
    public var fallBackGrey: Bool = true
    public let cache: Bool
    
    public init(
        url: URL?,
        option: Option,
        fallbackURL: URL? = nil,
        fallBackImg: UIImage? = nil,
        fallBackGrey: Bool = true,
        cache: Bool = true
    ) {
        self.url = url
        self.option = option
        self.fallbackURL = fallbackURL
        self.fallBackImg = fallBackImg
        self.fallBackGrey = fallBackGrey
        self.cache = cache
    }
    
    public enum Option {
        case max
        case mid
        case min
        case custom(CGSize)
        
        var size: CGSize {
            return switch self {
            case .max:
                CGSize(width: 500, height: 500)
            case .mid:
                CGSize(width: 300, height: 300)
            case .min:
                CGSize(width: 100, height: 100)
            case let .custom(size):
                size
            }
        }
    }
    
    public var body: some View {
        if cache {
            cashBody
        } else {
            noCacheBody
        }
    }
    
    private var cashBody: some View {
        imageView
            .loadDiskFileSynchronously(false) // 동기적 디스크 호출 안함
            .cancelOnDisappear(true) // 사라지면 취소
            .diskCacheExpiration(.days(7))  // 7일 후 디스크 캐시에서 만료
            .backgroundDecode(true) // 백그라운드에서 디코딩
            .processingQueue(.dispatch(DispatchQueue.global(qos: .userInitiated)))
            .retry(maxCount: 2, interval: .seconds(1))
            .fade(duration: 0.25)
            .resizable()
    }
    
    private var noCacheBody: some View {
        imageView
            .forceRefresh() // Cach 조회 취소
            .memoryCacheExpiration(.expired) // 메모리 캐시 즉시
            .diskCacheExpiration(.expired) // 디스크 캐시 즉시 무효
            .cacheOriginalImage(false) // 원본 이미지 캐시 안함
            .backgroundDecode(true)
            .processingQueue(.dispatch(DispatchQueue.global(qos: .userInitiated)))
            .retry(maxCount: 1, interval: .seconds(0.5))
            .cancelOnDisappear(true)
            .fade(duration: 0.25)
            .resizable()
    }
    
    private var imageView: KFImage {
        KFImage(url)
            .scaleFactor(UIScreen.main.scale)
            .setProcessor(
                DownsamplingImageProcessor(
                    size: option.size
                )
            )
            .placeholder {
                Group {
                    if let fallBackImg {
                        Image(uiImage: fallBackImg)
                            .resizable()
                            .saturation(fallBackGrey ? 0 : 1)
                    } else if let fallbackURL {
                        KFImage(fallbackURL)
                            .resizable()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .foregroundStyle(.secondary)
                            .saturation(fallBackGrey ? 0 : 1)
                    }
                }
            }
            .onFailure { error in
                #if DEBUG
                Logger.error(error)
                #endif
            }
    }
}
