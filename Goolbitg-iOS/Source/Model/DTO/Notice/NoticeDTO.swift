//
//  NoticeDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/2/25.
//

import Foundation

struct NoticeDTO: DTO {
    /// 알림 아이디
    let id: Int
    /// 수신자 ID
    let receiverId: String
    /// 메세지 내용
    let message: String
    /// 알림 발송 날짜
    let publishDateTime: String
    /// 메시지 타입
    let type: NoticeTypeDTO?
    /// 메시지 읽었는지 여부
    let read: Bool
}

enum NoticeTypeDTO: String, DTO {
    case CHALLENGE
    case VOTE
    case CHAT
}
