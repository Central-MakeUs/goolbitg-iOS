//
//  BuyOrNotTabTypes.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 4/8/26.
//

import Foundation

public enum BuyOrNotTabInMode: Equatable, Hashable {
    case buyOrNot
    case records

    var title: String {
        switch self {
        case .buyOrNot:
            return "살까말까"
        case .records:
            return "기록"
        }
    }
}

/// 기록뷰 스위치 타입
public enum RecordType: Equatable, Hashable, CaseIterable {
    case writePost
    case joinChat

    var title: String {
        switch self {
        case .writePost:
            return "작성한 글"
        case .joinChat:
            return "참여한 토론방"
        }
    }
}

public enum ReportCase: Equatable, CaseIterable {
    case adult
    case fight
    case wrong
    case other

    var reason: String {
        switch self {
        case .adult:
            return "성적인 콘텐츠"
        case .fight:
            return "폭력적 또는 혐오스러운 콘텐츠"
        case .wrong:
            return "잘못된 정보"
        case .other:
            return "기타 사유"
        }
    }
}
