//
//  LottieBridgeView.swift
//  Utils
//
//  Created by Jae hyung Kim on 5/23/25.
//

import SwiftUI
import Lottie

public struct LottieBridgeView: View {
    
    public let dotLottieFileName: String
    public let loopMode: LottieBridgeLoopMode
    
    public init(
        dotLottieFileName: String,
        loopMode: LottieBridgeLoopMode
    ) {
        self.dotLottieFileName = dotLottieFileName
        self.loopMode = loopMode
    }
    
    public var body: some View {
        contentView
    }
}

extension LottieBridgeView {
    private var contentView: some View {
        LottieView {
            try await DotLottieFile.named(dotLottieFileName)
        }
        .playing(loopMode: loopMode.bridgeValue)
        .resizable()
    }
}

public enum LottieBridgeLoopMode: Hashable {
    /// Animation is played once then stops.
    case playOnce
    /// Animation will loop from beginning to end until stopped.
    case loop
    /// Animation will play forward, then backwards and loop until stopped.
    case autoReverse
    /// Animation will loop from beginning to end up to defined amount of times.
    case `repeat`(Float)
    /// Animation will play forward, then backwards a defined amount of times.
    case repeatBackwards(Float)
    
    var bridgeValue: LottieLoopMode {
        switch self {
        case .playOnce:
            return .playOnce
        case .loop:
            return .loop
        case .autoReverse:
            return .autoReverse
        case .repeat(let count):
            return .repeat(count)
        case .repeatBackwards(let count):
            return .repeatBackwards(count)
        }
    }
}
