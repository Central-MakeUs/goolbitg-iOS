//
//  ChatMapper.swift
//  Data
//
//  Created by Atlas on 4/3/26.
//

import Foundation
import ComposableArchitecture
import Utils

/// Maps between chat DTOs and app-facing entities
public final class ChatMapper: Sendable {

    private let buyOrNotMapper: BuyOrNotMapper

    public init(buyOrNotMapper: BuyOrNotMapper = BuyOrNotMapper()) {
        self.buyOrNotMapper = buyOrNotMapper
    }

    // MARK: - Message

    /// Maps inbound DTO to app-facing entity
    public func map(dto: ChatMessageDTO) -> ChatMessageEntity {
        ChatMessageEntity(
            id: dto.id,
            buyOrNotId: dto.buyOrNotId,
            userId: dto.userId,
            username: dto.username,
            content: dto.content,
            sentDateTime: dto.sentDateTime,
            sentAt: ChatMapper.parseSentDateTime(dto.sentDateTime)
        )
    }

    /// Transforms outbound request DTO to socket-compatible dictionary
    public func mapToOutboundPayload(dto: ChatSendRequestDTO) -> [String: Any] {
        [
            "userId": dto.userId,
            "username": dto.username,
            "content": dto.content
        ]
    }

    // MARK: - History page

    public func map(historyDTOs: [ChatHistoryMessageDTO], roomId: Int) -> [ChatMessageEntity] {
        historyDTOs.map { dto in
            ChatMessageEntity(
                id: dto.id,
                buyOrNotId: roomId,
                userId: "",
                username: dto.username,
                content: dto.content,
                sentDateTime: dto.sentDateTime,
                sentAt: ChatMapper.parseSentDateTime(dto.sentDateTime)
            )
        }
    }

    // MARK: - Room list

    public func map(roomListDTO: BuyOrNotPagedDTO<BuyOrNotDTO>) -> [ChatRoomCardEntity] {
        roomListDTO.items.compactMap { dto in
            let entity = buyOrNotMapper.toEntity(dto: dto)
            guard let intID = Int(entity.id) else { return nil }
            return ChatRoomCardEntity(postId: intID, card: entity)
        }
    }

    // MARK: - UI mapping helpers

    /// 채팅 메시지 -> UI 표시용 값 (날짜/시간 문자열, 좌우 정렬 정보)
    public func mapToUIValue(
        entity: ChatMessageEntity,
        currentUserId: String,
        currentUserName: String
    ) -> ChatUIMessage {
        let date = entity.sentAt ?? ChatMapper.parseSentDateTime(entity.sentDateTime) ?? Date()
        let dateString = DateManager.shared.format(format: .yyyymmddKorean, date: date)
        let timeString = ChatMapper.koreanTimeString(from: date)
        let isSelf = ChatMapper.isCurrentUserMessage(
            entity,
            currentUserId: currentUserId,
            currentUserName: currentUserName
        )
        return ChatUIMessage(
            id: entity.id,
            text: entity.content,
            dateString: dateString,
            timeString: timeString,
            isSelf: isSelf,
            userName: isSelf ? nil : entity.username
        )
    }

    // MARK: - Date helpers

    public static func parseSentDateTime(_ raw: String) -> Date? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: raw) { return d }
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: raw) { return d }

        let primary = DateFormatter()
        primary.locale = Locale(identifier: "en_US_POSIX")
        primary.timeZone = TimeZone(identifier: "Asia/Seoul")
        primary.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        if let d = primary.date(from: raw) { return d }

        let alt = DateFormatter()
        alt.locale = Locale(identifier: "en_US_POSIX")
        alt.timeZone = TimeZone(identifier: "Asia/Seoul")
        alt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d = alt.date(from: raw) { return d }

        return nil
    }

    public static func koreanTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a hh:mm"
        return formatter.string(from: date)
    }

    public static func isCurrentUserMessage(
        _ entity: ChatMessageEntity,
        currentUserId: String,
        currentUserName: String
    ) -> Bool {
        if !entity.userId.isEmpty {
            return entity.userId == currentUserId
        }
        return entity.username == currentUserName
    }
}

/// 채팅 화면 표시용 가벼운 값 타입
public struct ChatUIMessage: Sendable, Equatable, Hashable, Identifiable {
    public let id: Int
    public let text: String
    public let dateString: String
    public let timeString: String
    public let isSelf: Bool
    public let userName: String?

    public init(
        id: Int,
        text: String,
        dateString: String,
        timeString: String,
        isSelf: Bool,
        userName: String?
    ) {
        self.id = id
        self.text = text
        self.dateString = dateString
        self.timeString = timeString
        self.isSelf = isSelf
        self.userName = userName
    }
}

extension ChatMapper: DependencyKey {
    public static let liveValue: ChatMapper = ChatMapper()
}

extension DependencyValues {
    public var chatMapper: ChatMapper {
        get { self[ChatMapper.self] }
        set { self[ChatMapper.self] = newValue }
    }
}
