import Foundation

public struct ChatSocketEndpoint {
    public let baseURL: URL
    public let buyOrNotId: String

    public init(baseURL: URL, buyOrNotId: String) {
        self.baseURL = baseURL
        self.buyOrNotId = buyOrNotId
    }

    public var connectURL: URL {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return baseURL.appendingPathComponent("chat")
        }

        components.path = "/chat"
        components.query = nil
        components.fragment = nil

        return components.url ?? baseURL.appendingPathComponent("chat")
    }

    public var subscribeDestination: String {
        "/topic/chat/\(buyOrNotId)"
    }

    public var sendDestination: String {
        "/app/chat/\(buyOrNotId)"
    }
}
