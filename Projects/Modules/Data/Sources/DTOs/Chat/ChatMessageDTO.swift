import Foundation
import Domain

public struct ChatMessageDTO: DTO {
    let id: String
    let buyOrNotId: String
    let userId: String
    let username: String
    let content: String
    let sentDateTime: String
}
