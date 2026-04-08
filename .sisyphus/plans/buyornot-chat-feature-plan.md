# BuyOrNot Chat Feature Implementation Plan

## TL;DR
> **Summary**: Implement the BuyOrNot chat feature as a full vertical slice across Data and FeatureCommon, reusing the existing `ChatSocketEndpoint`, `ChatSocketClient`, `SocketManager`, `BuyOrNotRouter`, `BuyOrNotDTO`, `BuyOrNotPagedDTO`, `BuyOrNotMapper`, and TCA navigation flow. Add HTTP contracts for room-list/history retrieval, a Realm-backed local cache, and a real `ChattingViewFeature` reducer that hydrates from local DB, paginates older history upward, connects/subscribes to websocket updates, and sends outbound messages.
> **Deliverables**:
> - Router/DTO/mapper/repository/persistence additions for chat list + history
> - RealmSwift dependency exposure in Tuist helper + Data target wiring
> - Realm-backed chat local store under Data
> - FeatureCommon test target wiring for reducer verification
> - Real chat feature wiring in `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift`
> - Tests for DTOs, routers, mapper, websocket contract seam, persistence, and reducer behavior
> **Effort**: Large
> **Parallel**: YES - 4 waves
> **Critical Path**: T1 → T2/T3/T4 → T5/T6/T7 → T8

## Context
### Original Request
- Produce a planning-only markdown file under `.sisyphus/plans/` for the BuyOrNot chat feature.
- The implementation scope must cover:
  - chat room list APIs
  - chat history API
  - websocket chat flow
  - TCA feature wiring
  - RealmSwift-backed local persistence
- Follow the repo plan style used by `.sisyphus/plans/chat-socket-protocol.md`.
- The Realm DB design section must be written in Korean.

### Repository Facts Confirmed During Exploration
- Existing websocket contract builder already exists in `Projects/Modules/Data/Sources/SocketEndpoints/ChatSocketEndpoint.swift` and matches the required contract:
  - connect URL = `baseURL.appendingPathComponent("chat")`
  - subscribe destination = `/topic/chat/<buyOrNotId>`
  - send destination = `/app/chat/<buyOrNotId>`
- Existing thin websocket seam already exists in `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift`, but it only covers basic connect/listen/send and currently decodes IDs as `String`, which conflicts with the server samples that use numeric `id` and `buyOrNotId`.
- Existing chat wire models already exist:
  - `Projects/Modules/Data/Sources/RequestDTOs/Chat/ChatSendRequestDTO.swift`
  - `Projects/Modules/Data/Sources/DTOs/Chat/ChatMessageDTO.swift`
  - `Projects/Modules/Data/Sources/Entitys/Chat/ChatMessageEntity.swift`
  - `Projects/Modules/Data/Sources/Mappers/Chat/ChatMapper.swift`
- Existing `ChattingViewFeature` is still placeholder-only and currently has:
  - fake loading delay
  - fake pagination delay
  - no repository/service dependencies
  - no local cache hydration
  - no websocket lifecycle management
  - no real message source
- Existing `ChattingView` already supports the target UI flow:
  - renders date-sectioned `ChatListItem`
  - triggers `loadMoreIfNeeded(index)` from top cell appearance
  - uses current `userName` as navigation title with an existing inline TODO indicating server room name is not available
- Existing navigation handoff is already present:
  - `BuyOrNotTabViewFeature` obtains current user info and delegates to chat screen
  - `TabNavigationCoordinator` pushes `ChattingViewFeature.State(userName:userID:model:)`
- Data already has a test target in `Projects/Modules/Data/Project.swift`.
- `Tuist/Package.swift` already includes `realm-swift`, but `Plugins/TuistExtensions/ProjectDescriptionHelpers/AppSetting/Cores.swift` does not yet expose a `.realmSwift` helper and `Projects/Modules/Data/Project.swift` does not yet depend on Realm.
- Direct search found no existing production Realm usage, so local persistence must be introduced from scratch.

### Required Server Contracts (fixed and must be implemented exactly)
- WebSocket connection URL: `ws://<server_host>/chat`
- Subscribe destination: `/topic/chat/<buyOrNotId>`
- Send destination: `/app/chat/<buyOrNotId>`
- Send payload:
  ```json
  {"userId":"id0001","username":"nickname","content":"message to send"}
  ```
- Receive payload:
  ```json
  {"id":101,"buyOrNotId":2,"userId":"id0001","username":"nickname","content":"message other that other sent","sentDateTime":"2026-04-02T20:55:17.250011"}
  ```
- HTTP API 1: `GET /api/v1/buyOrNots/chat/list`
  - query: `userId` optional, `page: Int`, `size: Int`
  - response item shape: same as `BuyOrNotDTO`
- HTTP API 2 ambiguity from request text:
  - user mentioned `api/v1/buyOrNots/1/chat`
  - params include `postId: Int`, `chatLastId` optional
  - response is paged: `{ totalSize, totalPages, size, page, items: [...] }`

### Explicit Assumptions (decision-complete; do not reopen during implementation)
- **A1. Endpoint ambiguity resolution**: Treat `GET /api/v1/buyOrNots/{postId}/chat` as the **message history retrieval API**, not a separate room-list API. The room-list concern is satisfied by `GET /api/v1/buyOrNots/chat/list`.
- **A2. `chatLastId` semantics**: `chatLastId` is an optional cursor for loading older messages in descending-history requests. When omitted, the server returns the latest page for the room. When present, the server returns messages older than that message ID.
- **A3. History item shape**: The `items` inside `GET /api/v1/buyOrNots/{postId}/chat` use the same fields as the websocket receive payload: `id`, `buyOrNotId`, `userId`, `username`, `content`, `sentDateTime`.
- **A4. ID normalization**: Server samples show numeric `id` and `buyOrNotId`, while current chat DTO/entity files use `String`. Implementation should normalize these fields to `Int` at DTO/persistence boundaries and only stringify where the SwiftUI list requires `Identifiable` string IDs.
- **A5. Socket transport boundary**: Keep using the existing Socket.IO-based `SocketManager` + `ChatSocketClient` seam as the current repository pattern. If backend runtime proves STOMP-only and incompatible with `listen(event:)` / `emit(event:)`, stop implementation and file a transport mismatch report rather than burying protocol hacks inside `SocketManager`.
- **A6. Room name behavior**: The server does not provide a chat room name. Ignore room-name update handling for now and keep the current title behavior (`userName` passed during navigation) as the temporary display fallback.
- **A7. Optimistic sending**: Do not add speculative local echo objects with client-generated temporary IDs in v1. Clear the input on send intent only after the send use case accepts the payload, and rely on websocket echo/history refresh/Realm merge for the persisted visible message.

### Reuse vs New Work
#### Reuse As-Is or With Narrow Adjustments
- `Projects/Modules/Data/Sources/Routers/BuyOrNotRouter.swift`
- `Projects/Modules/Data/Sources/DTOs/BuyOrNot/BuyOrNotDTO.swift`
- `Projects/Modules/Data/Sources/DTOs/BuyOrNot/BuyOrNotPagedDTO.swift`
- `Projects/Modules/Data/Sources/Mappers/BuyOrNotMapper.swift`
- `Projects/Modules/Data/Sources/SocketEndpoints/ChatSocketEndpoint.swift`
- `Projects/Modules/Data/Sources/Support/SocketManager.swift`
- `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift`
- `Projects/Modules/Features/BuyOrNot/Sources/Main/BuyOrNotTabViewFeature.swift`
- `Projects/Modules/Features/Common/Sources/ChatView/ChattingView.swift`
- `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift`

#### New Files/Artifacts Expected
- `Projects/Modules/Data/Sources/DTOs/Chat/ChatHistoryPagedDTO.swift`
- `Projects/Modules/Data/Sources/Entitys/Chat/ChatRoomCardEntity.swift`
- `Projects/Modules/Data/Sources/Entitys/Chat/ChatHistoryPageEntity.swift`
- `Projects/Modules/Data/Sources/Mappers/Chat/ChatMapper.swift` (expanded to handle room-list, history-page, and message/UI mapping)
- `Projects/Modules/Data/Sources/Support/ChatRepository.swift`
- `Projects/Modules/Data/Sources/Support/ChatLocalStore.swift`
- `Projects/Modules/Data/Sources/Support/Actor/RealmActor.swift`
- `Projects/Modules/Data/Sources/LocalDB/Chat/RealmChatMessageObject.swift`
- `Projects/Modules/Data/Sources/LocalDB/Chat/RealmChatRoomObject.swift`
- `Projects/Modules/Features/Common/Tests/ChatView/ChattingViewFeatureTests.swift`
- `Projects/Modules/Data/Tests/Chat/**`

## Work Objectives
### Core Objective
Deliver a decision-complete execution plan for implementing BuyOrNot chat as a production feature, with explicit ownership across HTTP, websocket, reducer state, and Realm persistence layers so `/start-work` can proceed without reopening architectural choices.

### Deliverables
- Router additions for room list + message history under `BuyOrNotRouter`
- DTOs for chat history paging and any required chat room card reuse wrappers
- `ChatMapper` expansion that converts room-list, history-page, and message payloads into app-facing entities and date-sectioned UI inputs
- A chat repository in Data that orchestrates network, websocket, and Realm cache flows
- Realm persistence layer for per-room message storage and room-level sync metadata
- Real reducer logic in `ChattingViewFeature` for:
  - initial history load
  - upward pagination
  - websocket connect/subscribe lifecycle
  - outbound send
  - local persistence hydration
  - mapping server messages into current `ChatListItem` sections
- Tests covering router generation, DTO decoding, mapper behavior, websocket boundary behavior, persistence semantics, and TCA reducer effects

### Definition of Done (verifiable conditions with commands)
- `tuist build Data` succeeds.
- `tuist test Data` succeeds with chat contract + persistence tests.
- `tuist build FeatureCommon` succeeds.
- `tuist test FeatureCommon` succeeds with reducer tests because FeatureCommon test-target wiring is included in scope.
- `grep -n "RealmSwift" Projects/Modules/Data/Sources/**/*.swift` shows only Data-layer persistence usage, not Feature code directly.
- `grep -n "chat/list\|buyOrNots/.*/chat" Projects/Modules/Data/Sources/Routers/BuyOrNotRouter.swift` shows both HTTP endpoints are centralized in the existing router.
- `grep -n "Task.sleep" Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift` returns no fake loading timers.

### Must Have
- One authoritative HTTP router home: `BuyOrNotRouter`.
- One authoritative websocket endpoint builder home: `ChatSocketEndpoint`.
- One chat orchestration seam in Data that FeatureCommon depends on indirectly through dependencies, not raw networking code.
- Realm local hydration before or alongside remote refresh so previously cached room messages render immediately.
- Pagination must load older messages when top cells appear.
- Server room name remains out of scope; fallback title behavior must be preserved.
- Message grouping must preserve the current date-divider UI format used by `ChatListItem`.

### Must NOT Have (guardrails)
- No production code implementation inside this plan file.
- No direct Realm usage from SwiftUI Views.
- No room-name API invention.
- No destructive git operations.
- No replacement of `SocketManager` with a brand-new transport abstraction unless a verified transport incompatibility forces a follow-up architectural plan.
- No unresolved TBDs where a reasonable assumption is possible.

## Realm DB Structure / 설계 (한국어)
### 목적
- 채팅방 진입 시 서버 응답을 기다리지 않고 기존 메시지를 즉시 보여주기 위한 로컬 캐시를 구축한다.
- HTTP 이력 조회와 websocket 실시간 수신 결과를 하나의 저장소에서 병합하여 `ChattingViewFeature` 가 단일 데이터 흐름만 바라보도록 만든다.

### 메시지 Object 스키마
- 파일 후보: `Projects/Modules/Data/Sources/LocalDB/Chat/RealmChatMessageObject.swift`
- 권장 필드:
  - `messageId: Int` — 서버 메시지 PK
  - `roomId: Int` — `buyOrNotId`
  - `userId: String`
  - `username: String`
  - `content: String`
  - `sentDateTimeRaw: String`
  - `sentAt: Date?` — 정렬/섹션 계산용 파싱 결과
  - `createdAtLocal: Date` — 로컬 저장 시각
- 이유:
  - 서버 원본 문자열(`sentDateTimeRaw`)은 디버깅/재파싱 안정성을 위해 유지한다.
  - 실제 정렬과 UI 섹션 계산은 `sentAt` 를 우선 사용하고, 파싱 실패 시 `sentDateTimeRaw` 를 fallback 비교 키로 사용한다.

### Primary Key 선택 근거
- `messageId` 를 단일 primary key 로 사용한다.
- 이유:
  - websocket 수신 메시지와 HTTP history 메시지가 동일 서버 ID 를 공유한다고 가정했을 때 upsert 가 가장 단순하다.
  - 클라이언트 임시 ID 전략을 이번 범위에서 제외했으므로 복합 키보다 충돌 가능성이 낮다.
  - 중복 저장 방지와 merge 로직이 쉬워진다.

### 인덱싱 / 정렬 필드
- 인덱스 권장:
  - `roomId`
  - `sentAt`
  - 필요 시 `messageId`
- 조회 정렬 기준:
  - 기본 렌더링용은 `sentAt ASC`, 보조 기준 `messageId ASC`
  - 과거 페이지 커서 계산은 `messageId` 최소값 또는 `sentAt` 최소값을 함께 보관한다.
- 이유:
  - UI 는 오래된 메시지 → 최신 메시지 순서로 그리는 편이 date section 구성에 유리하다.
  - 서버 paging 커서는 `chatLastId` 이므로 최소 `messageId` 를 빠르게 찾을 수 있어야 한다.

### Room 단위 그룹화 / Room 메타데이터 Object
- 파일 후보: `Projects/Modules/Data/Sources/LocalDB/Chat/RealmChatRoomObject.swift`
- 최소 필드 권장:
  - `roomId: Int` (primary key)
  - `lastSyncedMessageId: Int?`
  - `oldestCachedMessageId: Int?`
  - `lastMessagePreview: String?`
  - `lastMessageSentAt: Date?`
  - `updatedAt: Date`
- 이유:
  - 메시지 테이블만으로도 채팅 화면은 구성 가능하지만, room-level sync metadata 가 있으면 초기 hydrate / pagination cursor / room list preview 관리가 단순해진다.
  - room name 은 서버 미제공이므로 metadata object 에도 저장하지 않는다.

### 페이지네이션 전략 (`chatLastId`, `sentDateTime`)
- 원칙:
  - 네트워크 요청은 `chatLastId` 기반으로 한다.
  - 로컬 렌더링 정렬과 섹션 계산은 `sentAt` 기반으로 한다.
- 초기 로드:
  - `chatLastId == nil` 로 최신 페이지 요청
  - 응답을 Realm 에 upsert 후 `sentAt ASC` 로 재조회하여 UI 구성
- 과거 메시지 추가 로드:
  - 현재 캐시에 있는 가장 작은 `messageId` 를 `chatLastId` 로 사용
  - 서버 응답을 Realm 에 upsert
  - 다시 `sentAt ASC` 로 조회하여 reducer state 갱신
- 이유:
  - 서버 계약은 ID cursor 이고, 화면 요구사항은 시간순 정렬이기 때문이다.

### WebSocket 이벤트 병합 전략
- websocket 수신 시 바로 Realm write 를 수행하고, write 성공 후 같은 room 의 메시지 목록을 재조회하여 reducer/UI 로 반영한다.
- merge 규칙:
  - `messageId` 기준 upsert
  - 이미 존재하는 메시지는 덮어쓰기 또는 no-op
  - 더 최신 메시지가 들어오면 room metadata 의 `lastSyncedMessageId`, `lastMessagePreview`, `lastMessageSentAt` 갱신
- 장점:
  - HTTP history / websocket / 재진입 hydrate 가 모두 같은 저장소를 통과하므로 중복 append 버그를 줄일 수 있다.

### Realm + TCA/Data 계층 동시성 주의사항
- Realm 객체를 reducer state 나 SwiftUI 계층으로 직접 넘기지 않는다. 항상 value type entity 로 변환해서 전달한다.
- `SocketManager` 가 actor 이므로 websocket 이벤트 처리도 actor 또는 직렬화된 Data 계층에서 Realm write 를 감싼다.
- Realm 접근은 `@RealmActor` 로 격리하고, `Realm(actor: RealmActor.shared)` 기반으로 동일한 actor 경계 안에서 열고 사용한다.
- TCA effect 내부에서 장시간 스트림 구독 중 Realm live object 를 잡고 있지 말고, write 후 즉시 entity 배열로 변환해 state 에 반영한다.
- 메인 스레드 전용 UI 코드와 백그라운드 Realm write 를 혼용할 때 thread-confined object 접근 오류가 가장 흔하므로, repository 반환 타입은 모두 `Sendable` value type 으로 제한한다.

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test policy: implementation and tests stay coupled per task.
- Evidence path convention: `.sisyphus/evidence/buyornot-chat-task-{N}-{slug}.txt`
- Verification layers:
  1. Router/DTO/mapper unit tests in Data
  2. Persistence tests with Realm in-memory configuration in Data
  3. Socket client contract tests with stubbed `SocketManager` boundary or seam wrapper
  4. Reducer tests in FeatureCommon using TCA `TestStore`
  5. Build validation for Data and FeatureCommon

## Execution Strategy
### Parallel Execution Waves
Wave 1: dependency exposure + wire contracts
- T1 Tuist/target dependency exposure for RealmSwift
- T2 HTTP router additions for chat list/history
- T3 DTO/entity normalization for chat message numeric IDs + paged history DTO

Wave 2: mapping + persistence foundation
- T4 `ChatMapper` expansion for room/history/UI mapping
- T5 `@RealmActor` + local objects + local store

Wave 3: repository + websocket orchestration
- T6 chat repository orchestration across HTTP/socket/Realm
- T7 `ChatSocketClient` contract hardening for numeric payloads and repository-facing APIs

Wave 4: feature wiring
- T8 `ChattingViewFeature` real reducer migration + tests

Final Wave: reviews + build/test sweep
- F1-F4

### Dependency Matrix (full)
- T1 blocks T5-T8 buildability if Realm target wiring is missing.
- T2 blocks T6 and T8 network flows.
- T3 blocks T4-T8 because all downstream layers depend on normalized message models.
- T4 and T5 block T6.
- T6 and T7 block T8.
- F1-F4 block completion.

## TODOs
> Implementation + Test = ONE task.
> Every task must include parallelization, acceptance criteria, and QA scenarios.

- [ ] 1. Expose RealmSwift in Tuist helpers and Data target

  **What to do**: Add a `TargetDependency.realmSwift` helper in `Plugins/TuistExtensions/ProjectDescriptionHelpers/AppSetting/Cores.swift` and add RealmSwift to `Projects/Modules/Data/Project.swift`. Do not add Realm directly to Feature targets; keep persistence owned by Data.
  **Must NOT do**: Do not introduce Realm dependencies into `Projects/Modules/Features/Common/Project.swift`. Do not change unrelated packages or target graphs.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [5, 6, 7, 8 buildability] | Blocked By: []

  **References**:
  - `Tuist/Package.swift:19-36` — Realm package already declared
  - `Plugins/TuistExtensions/ProjectDescriptionHelpers/AppSetting/Cores.swift:52-58` — network dependency helper style
  - `Projects/Modules/Data/Project.swift:23-38` — Data dependency list

  **Acceptance Criteria**:
  - [ ] Data target can import `RealmSwift`.
  - [ ] Feature targets do not gain direct Realm dependencies.
  - [ ] `tuist build Data` succeeds after dependency wiring.

  **QA Scenarios**:
  ```
  Scenario: Data target resolves RealmSwift
    Tool: Bash
    Steps: Run `tuist build Data`
    Expected: Build succeeds and Data can compile Realm imports
    Evidence: .sisyphus/evidence/buyornot-chat-task-1-realm-build.txt

  Scenario: Realm dependency remains Data-only
    Tool: Grep
    Steps: Search `Projects/Modules/Features/**/Project.swift` for `realmSwift`
    Expected: No Feature project directly adds RealmSwift
    Evidence: .sisyphus/evidence/buyornot-chat-task-1-realm-boundary.txt
  ```

  **Commit**: YES | Message: `build(data): expose realm dependency for chat persistence`

- [ ] 2. Extend `BuyOrNotRouter` for chat room list and chat history

  **What to do**: Add router cases under `Projects/Modules/Data/Sources/Routers/BuyOrNotRouter.swift` for:
  - `buyOrNotChatList(userId: String?, page: Int, size: Int)` → `GET /buyOrNots/chat/list`
  - `buyOrNotChatHistory(postId: Int, chatLastId: Int?)` → `GET /buyOrNots/{postId}/chat`
  Query generation must include optional `userId` only when provided and optional `chatLastId` only when provided.
  **Must NOT do**: Do not create a separate `ChatRouter.swift`. Do not reinterpret `/buyOrNots/{postId}/chat` as a second room-list API.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [6, 8] | Blocked By: []

  **References**:
  - `Projects/Modules/Data/Sources/Routers/BuyOrNotRouter.swift:12-118` — existing router ownership pattern

  **Acceptance Criteria**:
  - [ ] Router generates `/api/v1/buyOrNots/chat/list?page=<>&size=<>` with optional `userId`.
  - [ ] Router generates `/api/v1/buyOrNots/{postId}/chat` with optional `chatLastId` query.
  - [ ] Existing BuyOrNot router cases continue to compile unchanged.

  **QA Scenarios**:
  ```
  Scenario: Chat room list router query generation
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Unit tests assert URL path, method, and optional query composition
    Evidence: .sisyphus/evidence/buyornot-chat-task-2-router-room-list.txt

  Scenario: Chat history router query generation
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Unit tests assert `/buyOrNots/{postId}/chat` path and conditional `chatLastId`
    Evidence: .sisyphus/evidence/buyornot-chat-task-2-router-history.txt
  ```

  **Commit**: YES | Message: `feat(data): add buyornot chat router endpoints`

- [ ] 3. Normalize chat DTOs/entities for server history + socket payloads

  **What to do**: Update or replace current chat DTO/entity files so server receive/history payloads decode numeric IDs exactly. Add:
  - `Projects/Modules/Data/Sources/DTOs/Chat/ChatHistoryPagedDTO.swift`
  - updated `ChatMessageDTO` with `id: Int`, `buyOrNotId: Int`
  - `Projects/Modules/Data/Sources/Entitys/Chat/ChatHistoryPageEntity.swift`
  - `Projects/Modules/Data/Sources/Entitys/Chat/ChatRoomCardEntity.swift` for room-list entries mapped from existing BuyOrNot card payload shape
  **Must NOT do**: Do not leave message IDs as `String` in the Data layer. Do not create duplicate room-card payload structs if `BuyOrNotDTO` can be reused safely.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [4, 5, 6, 7, 8] | Blocked By: []

  **References**:
  - `Projects/Modules/Data/Sources/DTOs/Chat/ChatMessageDTO.swift`
  - `Projects/Modules/Data/Sources/Entitys/Chat/ChatMessageEntity.swift`
  - `Projects/Modules/Data/Sources/DTOs/BuyOrNot/BuyOrNotDTO.swift`
  - `Projects/Modules/Data/Sources/DTOs/BuyOrNot/BuyOrNotPagedDTO.swift`

  **Acceptance Criteria**:
  - [ ] Exact sample websocket payload decodes successfully.
  - [ ] Exact sample history page payload decodes successfully.
  - [ ] Room-list API can map from existing `BuyOrNotDTO` shape without schema duplication unless a wrapper DTO is strictly necessary.

  **QA Scenarios**:
  ```
  Scenario: Websocket payload decoding matches server sample
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Tests decode numeric `id` and `buyOrNotId` plus `sentDateTime`
    Evidence: .sisyphus/evidence/buyornot-chat-task-3-socket-dto.txt

  Scenario: History page payload decoding works
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Tests decode paged response with `items` of chat messages
    Evidence: .sisyphus/evidence/buyornot-chat-task-3-history-dto.txt
  ```

  **Commit**: YES | Message: `feat(data): normalize chat message and history models`

- [ ] 4. Expand `ChatMapper` for room cards, history pages, and UI-friendly message values

  **What to do**: Expand `Projects/Modules/Data/Sources/Mappers/Chat/ChatMapper.swift` so it:
  - map room-list payloads to `ChatRoomCardEntity`
  - map history DTOs to `ChatHistoryPageEntity`
  - convert `ChatMessageEntity` into a reducer-friendly plain value that includes parsed `Date`, `dateString`, `timeString`, and left/right ownership metadata
  Reuse formatting utilities from `Projects/Modules/Utils/Sources/Manager/DateManager.swift` where possible.
  **Must NOT do**: Do not push date parsing into SwiftUI Views. Do not let `ChattingViewFeature` decode raw DTOs directly.

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: [6, 8] | Blocked By: [3]

  **References**:
  - `Projects/Modules/Data/Sources/Mappers/Chat/ChatMapper.swift`
  - `Projects/Modules/Data/Sources/Mappers/BuyOrNotMapper.swift`
  - `Projects/Modules/Utils/Sources/Manager/DateManager.swift`

  **Acceptance Criteria**:
  - [ ] Mapper tests cover room-card mapping correctness.
  - [ ] Mapper tests cover history-page metadata and item mapping.
  - [ ] Date/time strings match current chat UI expectations for Korean presentation.

  **QA Scenarios**:
  ```
  Scenario: Room list mapper preserves BuyOrNot card semantics
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Tests validate product name, price, reasons, and vote counts mapping
    Evidence: .sisyphus/evidence/buyornot-chat-task-4-room-mapper.txt

  Scenario: Chat UI value mapping generates date/time labels
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Tests validate date section string and bubble time string generation
    Evidence: .sisyphus/evidence/buyornot-chat-task-4-ui-mapper.txt
  ```

  **Commit**: YES | Message: `feat(data): expand chat mapper for room and history flows`

- [ ] 5. Introduce Realm-backed chat local store

  **What to do**: Add a Data-only persistence layer including:
  - `Projects/Modules/Data/Sources/Support/Actor/RealmActor.swift`
  - `RealmChatMessageObject`
  - `RealmChatRoomObject`
  - `ChatLocalStore` with APIs for:
    - load cached messages by room ordered ascending
    - upsert history page
    - upsert incoming websocket message
    - derive oldest cached message ID for pagination
    - clear room cache if needed for hard refresh
  Use `@RealmActor` as the sole Realm access boundary. Follow the actor-isolated Realm pattern so local store reads/writes open Realm with `try await Realm(actor: RealmActor.shared)` or the equivalent actor-bound initialization path validated against the Realm Swift API version in use. Keep in-memory Realm configuration for tests.
  **Must NOT do**: Do not expose Realm `Object` subclasses outside Data. Do not rely on live Realm objects in reducer state.

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: [6, 8] | Blocked By: [1, 3]

  **References**:
  - `Projects/Modules/Data/Project.swift`
  - Realm Swift actor-isolated Realm docs / PR #8197 (`Add actor-isolated Realms with async writes`)
  - Korean Realm design section in this plan

  **Acceptance Criteria**:
  - [ ] Realm reads/writes are only performed inside `@RealmActor`-isolated APIs.
  - [ ] History pages upsert without duplicate messages.
  - [ ] Websocket message upsert updates room metadata.
  - [ ] Local queries return ascending message order suitable for `ChatListItem` generation.

  **QA Scenarios**:
  ```
  Scenario: History page upsert de-duplicates by messageId
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: In-memory Realm tests prove repeated inserts do not duplicate rows
    Evidence: .sisyphus/evidence/buyornot-chat-task-5-realm-dedup.txt

  Scenario: Realm access stays actor-isolated
    Tool: Bash
    Steps: Run `tuist test Data` and inspect the local-store test coverage for actor-isolated read/write entry points
    Expected: Tests exercise only `@RealmActor`-owned store APIs and do not require passing live Realm objects across boundaries
    Evidence: .sisyphus/evidence/buyornot-chat-task-5-realm-actor.txt

  Scenario: Pagination cursor derives from oldest cached message
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Tests verify `oldestCachedMessageId` reflects the smallest stored messageId per room
    Evidence: .sisyphus/evidence/buyornot-chat-task-5-realm-cursor.txt
  ```

  **Commit**: YES | Message: `feat(data): add realm chat local store`

- [ ] 6. Build a chat repository that orchestrates HTTP, websocket, and Realm

  **What to do**: Create `Projects/Modules/Data/Sources/Support/ChatRepository.swift` (or `Repositories/ChatRepository.swift` if repo conventions require) that owns these feature-facing operations:
  - fetch chat room list page
  - hydrate cached room messages
  - fetch latest history page and persist it
  - fetch older history page using local oldest ID as `chatLastId`
  - connect socket for a room
  - subscribe to incoming messages and persist them
  - send outbound message via `ChatSendRequestDTO`
  The repository should return value entities/streams only.
  **Must NOT do**: Do not let `ChattingViewFeature` talk to `networkManager`, `ChatSocketClient`, and `ChatLocalStore` separately. Do not expose raw DTOs or Realm objects across the repository boundary.

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: [8] | Blocked By: [2, 4, 5]

  **References**:
  - `Projects/Modules/Data/Sources/Support/NetworkManager.swift`
  - `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift`
  - `Projects/Modules/Data/Sources/Mappers/BuyOrNotMapper.swift`

  **Acceptance Criteria**:
  - [ ] One repository call path exists for initial hydrate + remote refresh.
  - [ ] Pagination uses `chatLastId` from local store metadata/cursor, not reducer guesswork.
  - [ ] Incoming websocket messages are persisted before Feature receives updated message values.

  **QA Scenarios**:
  ```
  Scenario: Initial load hydrates cache then refreshes network
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Repository tests prove cached data can be emitted before remote page merge
    Evidence: .sisyphus/evidence/buyornot-chat-task-6-initial-flow.txt

  Scenario: Send flow uses exact outbound payload contract
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Repository/socket seam tests assert payload keys are exactly userId, username, content
    Evidence: .sisyphus/evidence/buyornot-chat-task-6-send-contract.txt
  ```

  **Commit**: YES | Message: `feat(data): add chat repository orchestration`

- [ ] 7. Harden `ChatSocketClient` for real server payloads and repository lifecycle

  **What to do**: Update `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift` so it:
  - decodes numeric `id` and `buyOrNotId`
  - exposes repository-friendly async APIs for connect, disconnect, subscribe, lifecycle, and errors
  - keeps chat protocol ownership in this file rather than `SocketManager`
  - preserves the exact destination/payload contract supplied by `ChatSocketEndpoint` + `ChatSendRequestDTO`
  **Must NOT do**: Do not move chat strings into `SocketManager`. Do not silently coerce malformed payloads into partial messages.

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: [8] | Blocked By: [3]

  **References**:
  - `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift`
  - `Projects/Modules/Data/Sources/Support/SocketManager.swift`
  - `Projects/Modules/Data/Sources/SocketEndpoints/ChatSocketEndpoint.swift`

  **Acceptance Criteria**:
  - [ ] Exact websocket receive sample decodes end-to-end through socket seam tests.
  - [ ] Socket seam remains protocol-specific while `SocketManager` stays transport-generic.
  - [ ] Lifecycle/error observation APIs are usable by repository/reducer cleanup flows.

  **QA Scenarios**:
  ```
  Scenario: Websocket contract boundaries hold
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Tests validate connect URL, subscribe destination, send destination, and numeric payload decoding
    Evidence: .sisyphus/evidence/buyornot-chat-task-7-socket-boundary.txt

  Scenario: SocketManager remains protocol-free
    Tool: Grep
    Steps: Search `Projects/Modules/Data/Sources/Support/SocketManager.swift` for `topic/chat|app/chat|buyOrNotId`
    Expected: No chat protocol strings in SocketManager
    Evidence: .sisyphus/evidence/buyornot-chat-task-7-socket-manager-boundary.txt
  ```

  **Commit**: YES | Message: `feat(data): harden chat socket client for real contracts`

- [ ] 8. Replace placeholder `ChattingViewFeature` with the real chat reducer flow

  **What to do**: Rework `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift` so the reducer:
  - initializes product section from incoming `model` as today
  - loads cached messages on `onAppear`
  - triggers initial remote history fetch
  - starts websocket connect + subscribe lifecycle for `model.id`
  - listens for repository message updates and maps them into `ChatListItem`
  - supports upward pagination from `loadMoreIfNeeded(index)`
  - handles send tapped / return key send
  - handles socket/repository failures with stateful error presentation if the design already has a shared alert pattern
  - removes fake `Task.sleep` loading/paging behavior
  - keeps the current `userName` title fallback because server room name is unavailable
  Prefer a small internal reducer state model such as:
  - `messages: IdentifiedArray` or `[ChatMessage]`
  - `oldestLoadedMessageId: Int?`
  - `hasNextPage: Bool`
  - `isInitialLoading`
  - `isPaging`
  - `isSocketConnected`
  - `sendText`
  - optional alert/error state
  This task must also update `Projects/Modules/Features/Common/Project.swift` to add a FeatureCommon unit-test target that compiles `Projects/Modules/Features/Common/Tests/**`, and it must add `Projects/Modules/Features/Common/Tests/ChatView/ChattingViewFeatureTests.swift` so reducer verification is executable with a fixed command.
  **Must NOT do**: Do not rewrite `ChattingView.swift` beyond minimal binding compatibility fixes unless required. Do not fetch room name from a non-existent API.

  **Parallelization**: Can Parallel: NO | Wave 4 | Blocks: [Final Verification] | Blocked By: [1, 2, 3, 4, 5, 6, 7]

  **References**:
  - `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift`
  - `Projects/Modules/Features/Common/Sources/ChatView/ChattingView.swift`
  - `Projects/Modules/Features/Common/Project.swift`
  - `Projects/Modules/Features/BuyOrNot/Sources/Main/BuyOrNotTabViewFeature.swift`
  - `Projects/Modules/Features/Tab/Sources/Tab/TabNavigationCoordinator.swift`

  **Acceptance Criteria**:
  - [ ] `Projects/Modules/Features/Common/Project.swift` declares a FeatureCommon test target so `tuist test FeatureCommon` is a valid command.
  - [ ] `Projects/Modules/Features/Common/Tests/ChatView/ChattingViewFeatureTests.swift` exists and covers initial load, pagination, and send flows.
  - [ ] `onAppear` hydrates cached messages and starts real remote/socket flows.
  - [ ] Top-cell appearance loads older history exactly once per page boundary.
  - [ ] Send action delegates to repository and clears text only on accepted send flow.
  - [ ] Reducer builds current date-sectioned `ChatListItem` output from persisted/domain messages.
  - [ ] Placeholder loading timers are removed.

  **QA Scenarios**:
  ```
  Scenario: FeatureCommon reducer tests are wired and discoverable
    Tool: Bash
    Steps: Run `tuist build FeatureCommon` then `tuist test FeatureCommon`
    Expected: FeatureCommon builds and discovers `ChattingViewFeatureTests` without manifest or target-graph errors
    Evidence: .sisyphus/evidence/buyornot-chat-task-8-test-target.txt

  Scenario: Initial load hydrates cache then remote history
    Tool: Bash
    Steps: Run `tuist test FeatureCommon`
    Expected: TestStore proves cached data appears before remote merge and loading state ends correctly
    Evidence: .sisyphus/evidence/buyornot-chat-task-8-initial-reducer.txt

  Scenario: Upward pagination loads older messages once
    Tool: Bash
    Steps: Run `tuist test FeatureCommon`
    Expected: `loadMoreIfNeeded(0)` triggers only when `hasNextPage && !isPaging && !isInitialLoading`
    Evidence: .sisyphus/evidence/buyornot-chat-task-8-pagination-reducer.txt

  Scenario: Send success and failure are both handled
    Tool: Bash
    Steps: Run `tuist test FeatureCommon`
    Expected: Success clears input and failure preserves/reports recoverable state as designed
    Evidence: .sisyphus/evidence/buyornot-chat-task-8-send-reducer.txt
  ```

  **Commit**: YES | Message: `feat(common): wire real buyornot chat reducer`

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
- [ ] F1. Plan Compliance Audit
  - Validate that implementation exactly matches the assumptions and required contracts in this plan.
  - **QA Scenario**:
    ```
    Scenario: Implementation matches plan assumptions and server contracts
      Tool: Bash + manual diff review against this plan
      Steps: Run `grep -n "chat/list\|buyOrNots/.*/chat" Projects/Modules/Data/Sources/Routers/BuyOrNotRouter.swift` and `grep -n "topic/chat\|app/chat\|/chat" Projects/Modules/Data/Sources/Support/SocketManager.swift`, then compare implementation outputs against assumptions A1-A7 and task acceptance criteria
      Expected: Endpoint meaning, ID normalization, room-name fallback, and transport boundary all match this plan
      Evidence: .sisyphus/evidence/buyornot-chat-final-f1-plan-compliance.txt
    ```
- [ ] F2. Code Quality Review
  - Validate file ownership, dependency boundaries, and lack of Feature↔Realm leakage.
  - **QA Scenario**:
    ```
    Scenario: File ownership and dependency boundaries remain clean
      Tool: Grep + manual diff review
      Steps: Search `Projects/Modules/Features/**/*.swift` for `RealmSwift|Realm\(` and search `Projects/Modules/Features/**/Project.swift` for `realmSwift`, then inspect changed files for mapper/repository/local-store boundary violations
      Expected: Realm usage/dependency stays inside Data and changed files respect mapper/repository/local-store ownership
      Evidence: .sisyphus/evidence/buyornot-chat-final-f2-code-quality.txt
    ```
- [ ] F3. QA Execution
  - Run full build/test wave and confirm reducer, persistence, DTO, router, and socket boundary coverage.
  - **QA Scenario**:
    ```
    Scenario: End-to-end automated verification wave passes
      Tool: Bash
      Steps: Run `tuist build Data`, `tuist test Data`, `tuist build FeatureCommon`, `tuist test FeatureCommon`, `grep -n "Task.sleep" Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift`, and `grep -n "topic/chat\|app/chat\|/chat" Projects/Modules/Data/Sources/Support/SocketManager.swift`
      Expected: All build/test commands succeed, fake loader sleeps are gone from ChattingViewFeature, and SocketManager remains free of chat protocol strings
      Evidence: .sisyphus/evidence/buyornot-chat-final-f3-qa-wave.txt
    ```
- [ ] F4. Scope Fidelity Check
  - Confirm no room-name feature, no destructive git actions, and no unauthorized transport redesign slipped in.
  - **QA Scenario**:
    ```
    Scenario: Final scope stayed within approved feature boundaries
      Tool: Bash + manual diff review
      Steps: Run a scope-fidelity review against the final diff, then search `Projects/Modules/Features/Common/Sources/ChatView/**/*.swift` for `roomName|chatRoomName`
      Expected: Review confirms no invented room-name feature, no unauthorized transport redesign outside approved files, and no scope creep beyond this plan
      Evidence: .sisyphus/evidence/buyornot-chat-final-f4-scope-fidelity.txt
    ```

## Final Verification Commands
- `tuist build Data`
- `tuist test Data`
- `tuist build FeatureCommon`
- `tuist test FeatureCommon`
- `grep -n "Task.sleep" Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift`
- `grep -n "topic/chat\|app/chat\|/chat" Projects/Modules/Data/Sources/Support/SocketManager.swift`
- `grep -n "RealmSwift" Projects/Modules/Data/Sources/**/*.swift`

## Commit Strategy
- Commit after each numbered task.
- Keep Tuist/dependency wiring separate from runtime chat implementation.
- Keep router/model changes separate from persistence changes.
- Keep Data repository/persistence/socket changes separate from `FeatureCommon` reducer wiring.
- If task 7 exposes a real websocket transport mismatch with the backend, stop and create a dedicated mismatch report commit instead of patching around it inside `SocketManager`.

## Success Criteria
- `/start-work` can execute without reopening endpoint meaning, ID typing, pagination strategy, room-name behavior, or Realm ownership questions.
- HTTP room list and chat history APIs each have one clear role and one router home.
- Websocket connection/send/subscribe behavior exactly matches the fixed server contract.
- Realm persistence is introduced as a Data-only cache with explicit schema, indexing, and merge rules.
- `ChattingViewFeature` becomes a real chat reducer with cache hydration, remote history sync, upward pagination, websocket subscription, and outbound send handling.
- Verification covers DTO decoding/encoding, router queries, mapper correctness, websocket boundaries, Realm behavior, reducer flows, and repo build/test commands.
