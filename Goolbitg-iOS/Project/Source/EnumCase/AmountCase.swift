//
//  AmountCase.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import Foundation

enum AmountCase {
    case none
    /// 2000원
    case coffee
    /// 💡 5,000원 (~5,000원 이상)
    case taxi
    /// 💡 10,000원 (~10,000원 이상)
    case movie
    /// 💡 20,000원 (~20,000원 이상)
    case chicken
    /// 💡 30,000원 (~30,000원 이상)
    case hallCake
    /// 💡 40,000원 (~40,000원 이상)
    case stanly
    /// 💡 50,000원 (~50,000원 이상)
    case koreanBeef
    /// 💡 100,000원 (~100,000원 이상)
    case newWorld
    /// 200,000
    case airPods
    /// 300,000
    case appleWatch
    /// 400,000
    case dryCleaning
    /// 500,000
    case playStation
    
    var title: String {
        switch self {
        case .none :
            return "챌린지를 시작해보세요!"
        case .coffee:
            return "커피 한잔만큼 아꼈어요"
        case .taxi:
            return "기본 택시비만큼 아꼈어요"
        case .movie:
            return "영화 티켓 1장만큼 아꼈어요"
        case .chicken:
            return "치킨 1마리만큼 아꼈어요"
        case .hallCake:
            return "홀케이크 1개만큼 아꼈어요"
        case .stanly:
            return "스탠리 텀블러 1개만큼 아꼈어요"
        case .koreanBeef:
            return "한우세트만큼 아꼈어요"
        case .newWorld:
            return "신세계 상품권 1장만큼 아꼈어요"
        case .airPods:
            return "에어팟 1개만큼 아꼈어요"
        case .appleWatch:
            return "애플워치 1대만큼 아꼈어요"
        case .dryCleaning:
            return "다이슨 드라이기 1대만큼 아꼈어요"
        case .playStation:
            return "플레이스테이션 1대만큼 아꼈어요"
        }
    }
}
