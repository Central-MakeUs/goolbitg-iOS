//
//  DownImageView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import SwiftUI
import Kingfisher

struct DownImageView: View {

    let url: URL
    let option: Option
    var fallbackURL: URL? = nil
    var fallBackImg: UIImage? = nil
    
    enum Option {
        case max
        case mid
        case min
        case custom(CGSize)
        
        var size: CGSize {
            return switch self {
            case .max:
                CGSize(width: 300, height: 300)
            case .mid:
                CGSize(width: 200, height: 200)
            case .min:
                CGSize(width: 100, height: 100)
            case let .custom(size):
                size
            }
        }
    }
    
    var body: some View {
        KFImage(url)
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
                            .saturation(0)
                    } else {
                        KFImage(fallbackURL)
                            .resizable()
                    }
                }
            }
            .onFailure { error in
                #if DEBUG
                Logger.error(error)
                #endif
            }
            .loadDiskFileSynchronously(false) // 동기적 디스크 호출 안함
            .cancelOnDisappear(true) // 사라지면 취소
            .diskCacheExpiration(.days(7))  // 7일 후 디스크 캐시에서 만료
            .backgroundDecode(true) // 백그라운드에서 디코딩
            .processingQueue(.dispatch(DispatchQueue.global(qos: .userInitiated)))
            .retry(maxCount: 2, interval: .seconds(1))
            .resizable()
    }
}
