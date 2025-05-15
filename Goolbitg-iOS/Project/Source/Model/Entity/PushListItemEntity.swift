//
//  PushListItemEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/1/25.
//

import Foundation

/// 푸시 알림 아이템 Entity
struct PushListItemEntity: Entity {
    
    /// 알림 ID
    let id: String
    
    /// 수신자 ID
    let receiverId: String
    
    /// 챌린지 상단 케이스
    let challengeTopCase: PushListFilterCase
    
    /// 설명란
    let description: String
    
    /// 알림 발송 날짜 -> 몇분전, 몇시간전
    let pushDateTiem: String
    
    /// 메시지를 읽었는지 여부ㅓ
    let read: Bool
}
