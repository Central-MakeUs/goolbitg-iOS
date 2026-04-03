import Foundation

public struct ChatSocketEndpoint {
    public let baseURL: URL
    public let buyOrNotId: String

    public init(baseURL: URL, buyOrNotId: String) {
        self.baseURL = baseURL
        self.buyOrNotId = buyOrNotId
    }

    public var connectURL: URL {
        baseURL.appendingPathComponent("chat")
    }

    public var subscribeDestination: String {
        "/topic/chat/\(buyOrNotId)"
    }

    public var sendDestination: String {
        "/app/chat/\(buyOrNotId)"
    }
}
