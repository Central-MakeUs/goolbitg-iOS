//
//  NoticeMapper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/2/25.
//

import Foundation
import ComposableArchitecture
import Utils

public final class NoticeMapper: Sendable {
    
    public func toEntity(_ dtos: [NoticeDTO]) async -> [PushListItemEntity] {
        return await dtos.asyncMap { toEntity($0) }
    }
    
    public func toEntity(_ dto: NoticeDTO) -> PushListItemEntity {
        
        let caseOf: PushListFilterCase
        
        switch dto.type {
        case .CHALLENGE:
            caseOf = .challenge
        case .VOTE:
            caseOf = .voteResult
        case .CHAT:
            caseOf = .chatting
        case .none:
            caseOf = .challenge
        }
        
        let dateBeforeString = dto.publishDateTime
        
        let dateString = DateManager.shared.diffDate(dateBeforeString, format: .serverDateFormat)
        
        return PushListItemEntity(
            id: String(dto.id),
            receiverId: dto.receiverId,
            challengeTopCase: caseOf,
            description: dto.message,
            pushDateTiem: dateString,
            read: dto.read
        )
    }
}


extension NoticeMapper: DependencyKey {
    public static let liveValue: NoticeMapper = NoticeMapper()
}

extension DependencyValues {
    public var noticeMapper: NoticeMapper {
        get { self[NoticeMapper.self] }
        set { self[NoticeMapper.self] = newValue }
    }
}
