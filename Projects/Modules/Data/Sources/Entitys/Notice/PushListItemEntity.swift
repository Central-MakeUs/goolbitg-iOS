//
//  PushListItemEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/1/25.
//

import Foundation
import Domain

/// 푸시 알림 아이템 Entity
public struct PushListItemEntity: Entity {
    
    /// 알림 ID
    public let id: String
    
    /// 수신자 ID
    public let receiverId: String
    
    /// 챌린지 상단 케이스
    public let challengeTopCase: PushListFilterCase
    
    /// 설명란
    public let description: String
    
    /// 알림 발송 날짜 -> 몇분전, 몇시간전
    public let pushDateTiem: String
    
    /// 메시지를 읽었는지 여부ㅓ
    public let read: Bool
    
    public init(
        id: String,
        receiverId: String,
        challengeTopCase: PushListFilterCase,
        description: String,
        pushDateTiem: String,
        read: Bool
    ) {
        self.id = id
        self.receiverId = receiverId
        self.challengeTopCase = challengeTopCase
        self.description = description
        self.pushDateTiem = pushDateTiem
        self.read = read
    }
}
