import Foundation
import Domain

public struct ChatHistoryMessageDTO: DTO {
    public let id: Int
    public let username: String
    public let content: String
    public let sentDateTime: String

    public init(
        id: Int,
        username: String,
        content: String,
        sentDateTime: String
    ) {
        self.id = id
        self.username = username
        self.content = content
        self.sentDateTime = sentDateTime
    }
}
