import Foundation

public struct ChatSendRequestDTO: Encodable {
    public let userId: String
    public let username: String
    public let content: String

    public init(userId: String, username: String, content: String) {
        self.userId = userId
        self.username = username
        self.content = content
    }
}
