ChatSocketEndpointPlan Learnings
- Implemented two files per task: ChatSocketEndpoint.swift and ChatSocketEndpointTests.swift
- Used a minimal XCTest-based test when available; added a lightweight fallback path to avoid hard failures in environments without XCTest.
- Verified build success with `tuist build Data`.
- Next steps: optionally enhance tests to cover edge-cases and ensure SocketManager.swift contains no chat protocol strings in a dedicated contract.
