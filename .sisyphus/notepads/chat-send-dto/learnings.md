Plan: Implement ChatSendRequestDTO as Encodable with fields userId, username, content. Add tests to verify JSON encoding matches contract. Ensure no transport-layer or socket dependencies.

- Actions taken:
  - Added Projects/Modules/Data/Sources/RequestDTOs/Chat/ChatSendRequestDTO.swift with public struct ChatSendRequestDTO: Encodable and explicit initializer.
  - Added Tests/RequestDTOs/Chat/ChatSendRequestDTOTests.swift to verify encoding results against contract (userId, username, content).
  - Wrapped XCTest-based tests with #if canImport(XCTest) to avoid CI/tooling environments lacking XCTest.

- Verification plan:
  - Run `tuist build Data` and `tuist test Data` and confirm success.
