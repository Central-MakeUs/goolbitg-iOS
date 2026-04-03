# Chat Socket Protocol Organization

## TL;DR
> **Summary**: Keep `SocketManager` transport-only and define chat websocket contracts in Data artifact folders that mirror existing HTTP request/response conventions. Introduce one chat-specific endpoint builder and one thin chat-specific `SocketManager` consumer so URL/destination rules, payload models, and transport usage each have a single owner.
> **Deliverables**:
> - Data test target for protocol-level tests
> - `RequestDTOs/Chat/ChatSendRequestDTO.swift`
> - `DTOs/Chat/ChatMessageDTO.swift`
> - `Entitys/Chat/ChatMessageEntity.swift`
> - `Mappers/Chat/ChatMapper.swift`
> - `SocketEndpoints/ChatSocketEndpoint.swift`
> - `Support/ChatSocketClient.swift`
> **Effort**: Medium
> **Parallel**: YES - 2 waves
> **Critical Path**: T1 → T2 → T6

## Context
### Original Request
- Plan how to define and organize chat websocket protocol details that will use `Projects/Modules/Data/Sources/Support/SocketManager.swift`.
- Constraints:
  - Do not manage protocol definitions directly in `SocketManager.swift`
  - Do not manage websocket URL directly in `SocketManager.swift`
  - Follow the repository’s `RequestDTOs`-style organization where appropriate
- Chat contract:
  - connect URL: `ws://<server_host>/chat`
  - subscribe destination: `/topic/chat/<buyOrNotId>`
  - send destination: `/app/chat/<buyOrNotId>`
  - send payload: `{ userId, username, content }`
  - receive payload: `{ id, buyOrNotId, userId, username, content, sentDateTime }`

### Interview Summary
- No blocking ambiguities remain for plan generation.
- Organization choice is fixed: transport remains generic; chat contract types live outside `SocketManager` in Data module folders.
- `sentDateTime` will be preserved as raw `String` in the first version of the app-facing entity to avoid premature date parsing assumptions.
- Destination formatting belongs to a dedicated chat endpoint builder, not `SocketManager` and not HTTP `Routers/`.

### Metis Review (gaps addressed)
- Added explicit guardrail for the STOMP-like contract vs current Socket.IO transport shape.
- Added a mandatory Data test-target setup task because `Projects/Modules/Data` currently has no test folder/target.
- Added acceptance criteria for endpoint formatting, outbound encoding, inbound decoding, mapper normalization, and a grep-based guardrail that `SocketManager` stays protocol-free.
- Applied defaults instead of reopening scope:
  - chat folders live under `RequestDTOs/Chat`, `DTOs/Chat`, `Entitys/Chat`, `Mappers/Chat`
  - endpoint builder lives under `SocketEndpoints/`
  - one thin consumer `ChatSocketClient` owns the integration seam with `SocketManager`

## Work Objectives
### Core Objective
Define a decision-complete Data-layer structure for chat websocket contracts so chat payloads, destination strings, and transport usage are each owned by the correct layer and can be implemented without adding chat-specific rules into `SocketManager`.

### Deliverables
- `Projects/Modules/Data/Tests/**` plus Data test target wiring
- `Projects/Modules/Data/Sources/SocketEndpoints/ChatSocketEndpoint.swift`
- `Projects/Modules/Data/Sources/RequestDTOs/Chat/ChatSendRequestDTO.swift`
- `Projects/Modules/Data/Sources/DTOs/Chat/ChatMessageDTO.swift`
- `Projects/Modules/Data/Sources/Entitys/Chat/ChatMessageEntity.swift`
- `Projects/Modules/Data/Sources/Mappers/Chat/ChatMapper.swift`
- `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift`

### Definition of Done (verifiable conditions with commands)
- `tuist build Data` succeeds after all artifacts are added.
- `tuist test Data` executes chat protocol tests successfully.
- `grep -n "topic/chat\|app/chat\|/chat" Projects/Modules/Data/Sources/Support/SocketManager.swift` returns no protocol constants added there.
- `grep -n "struct ChatSendRequestDTO\|struct ChatMessageDTO\|struct ChatMessageEntity\|struct ChatSocketEndpoint\|actor ChatSocketClient\|final class ChatSocketClient" Projects/Modules/Data/Sources/**/*.swift` returns the expected artifact definitions.

### Must Have
- `SocketManager` remains generic transport support.
- Chat connect/send/subscribe path rules are centralized in one builder type.
- Outbound payload shape is encoded by a request DTO only.
- Inbound payload shape is decoded by a response DTO only.
- App-facing feature code can depend on an entity rather than a raw DTO.
- Protocol-level tests cover formatting/encoding/decoding/mapping.

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- No chat destination strings in `SocketManager.swift`.
- No websocket host resolution in `SocketManager.swift`.
- No generic “websocket abstraction framework” beyond the specific chat protocol needs.
- No UI/feature/repository/persistence work in this plan.
- No speculative STOMP client migration in this plan; only capture the compatibility validation seam.

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: tests-after + XCTest (new Data test target must be added first)
- QA policy: Every task includes agent-executed checks
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks for max parallelism.

Wave 1: test infrastructure + endpoint builder + wire models
- T1 test target wiring
- T2 chat endpoint builder
- T3 outbound request DTO
- T4 inbound response DTO

Wave 2: app-facing mapping + thin transport consumer
- T5 entity + mapper
- T6 `ChatSocketClient` integration seam

### Dependency Matrix (full, all tasks)
- T1 blocks T2-T6 verification, but not their coding.
- T2 blocks T6.
- T3 and T4 block T5.
- T2, T3, T4, T5 block T6.
- F1-F4 block completion.

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 4 tasks → `unspecified-high`, `quick`
- Wave 2 → 2 tasks → `deep`, `unspecified-high`
- Final Wave → 4 review tasks → `oracle`, `unspecified-high`, `deep`

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. Add Data test target and scaffolding

  **What to do**: Update `Projects/Modules/Data/Project.swift` so Data has a test target/scheme path that includes `Projects/Modules/Data/Tests/**`. Create the minimal test folder structure needed for subsequent chat protocol tests to compile and run under `tuist test Data`.
  **Must NOT do**: Do not change non-Data projects. Do not add feature/UI tests. Do not change runtime source organization in this task.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: Tuist manifest and test-target wiring affects module build graph.
  - Skills: `[]` — No special skill needed.
  - Omitted: `swift-concurrency` — No concurrency-specific work here.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [2, 3, 4, 5, 6 verification] | Blocked By: []

  **References**:
  - Pattern: `Projects/Modules/Data/Project.swift:11-25` — current Data framework target and dependency style
  - Pattern: `Projects/Modules/Data/Sources/**` — current Data source glob only; tests are not yet included

  **Acceptance Criteria**:
  - [ ] `Projects/Modules/Data/Project.swift` declares a Data test target/scheme path that allows `tuist test Data` to execute.
  - [ ] `Projects/Modules/Data/Tests/` exists with at least one compile-valid test file scaffold.
  - [ ] `tuist build Data` still succeeds after manifest changes.

  **QA Scenarios**:
  ```
  Scenario: Data test target is wired
    Tool: Bash
    Steps: Run `tuist build Data` then `tuist test Data`
    Expected: Build succeeds and test runner discovers Data tests without manifest errors
    Evidence: .sisyphus/evidence/task-1-data-test-target.txt

  Scenario: Data tests path is missing from manifest
    Tool: Bash
    Steps: Run `grep -n "Tests" Projects/Modules/Data/Project.swift`
    Expected: Output proves the manifest includes a tests path/target, preventing silent omission
    Evidence: .sisyphus/evidence/task-1-data-test-target-grep.txt
  ```

  **Commit**: YES | Message: `build(data): add test target scaffolding for chat socket contracts` | Files: [`Projects/Modules/Data/Project.swift`, `Projects/Modules/Data/Tests/**`]

- [x] 2. Add centralized chat endpoint builder

  **What to do**: Create `Projects/Modules/Data/Sources/SocketEndpoints/ChatSocketEndpoint.swift` that owns only three formatted outputs: `connectURL`, `subscribeDestination`, and `sendDestination`. The type must accept externally injected host/base URL inputs plus `buyOrNotId`, and produce exactly `/chat`, `/topic/chat/<buyOrNotId>`, and `/app/chat/<buyOrNotId>` contract strings in one place.
  **Must NOT do**: Do not place these strings in `SocketManager.swift`. Do not reuse HTTP `Routers/` for websocket endpoint formatting. Do not resolve environment host inside `SocketManager`.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: Single-artifact contract builder with deterministic formatting logic.
  - Skills: `[]` — No extra skill required.
  - Omitted: `swift-concurrency` — No concurrency logic needed.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [6] | Blocked By: [1 for tests]

  **References**:
  - Pattern: `Projects/Modules/Data/Sources/Support/SocketManager.swift:17-39` — transport-only config injection and no protocol ownership
  - Pattern: `Projects/Modules/Data/Sources/Support/SocketManager.swift:122-149` — `configure(_:)` accepts externally built connection config
  - Pattern: `Projects/Modules/Data/Sources/RequestDTOs/Common/CheckPayload.swift:10-38` — dynamic protocol payload formatting lives outside transport support

  **Acceptance Criteria**:
  - [ ] `ChatSocketEndpoint` exposes exactly one source of truth for connect/send/subscribe strings.
  - [ ] `connectURL` appends `/chat` to externally injected host/base URL without hardcoding the host itself.
  - [ ] `subscribeDestination` and `sendDestination` match `/topic/chat/<buyOrNotId>` and `/app/chat/<buyOrNotId>` exactly.

  **QA Scenarios**:
  ```
  Scenario: Endpoint formatting matches server contract
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Endpoint tests prove connect/send/subscribe formatting for a sample buyOrNotId
    Evidence: .sisyphus/evidence/task-2-chat-endpoint-tests.txt

  Scenario: Protocol strings are not leaked into SocketManager
    Tool: Bash
    Steps: Run `grep -n "topic/chat\|app/chat\|/chat" Projects/Modules/Data/Sources/Support/SocketManager.swift`
    Expected: No matches returned from SocketManager.swift
    Evidence: .sisyphus/evidence/task-2-socket-manager-no-protocol-strings.txt
  ```

  **Commit**: YES | Message: `feat(data): add chat socket endpoint builder` | Files: [`Projects/Modules/Data/Sources/SocketEndpoints/ChatSocketEndpoint.swift`, `Projects/Modules/Data/Tests/**`]

- [x] 3. Add outbound chat request DTO

  **What to do**: Create `Projects/Modules/Data/Sources/RequestDTOs/Chat/ChatSendRequestDTO.swift` as a small `Encodable` struct with exactly `userId`, `username`, and `content`. Keep it transport-payload focused with no destination/path logic and no socket manager dependency.
  **Must NOT do**: Do not include `buyOrNotId` in the body unless the server contract changes. Do not include timestamps, transport headers, or protocol wrappers.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: Small deterministic outbound contract file.
  - Skills: `[]` — No extra skill required.
  - Omitted: `swift-concurrency` — Not relevant.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [5, 6] | Blocked By: [1 for tests]

  **References**:
  - Pattern: `Projects/Modules/Data/Sources/RequestDTOs/BuyOrNot/BuyOrNotVoteRequestDTO.swift:10-21` — feature-scoped outbound `Encodable` request struct style
  - Pattern: `Projects/Modules/Data/Sources/RequestDTOs/User/UserPatternRequestModel.swift:10-31` — flat request body modeling with explicit initializer

  **Acceptance Criteria**:
  - [ ] `ChatSendRequestDTO` is `Encodable` and contains exactly `userId`, `username`, `content`.
  - [ ] Encoding tests assert the produced JSON keys match the server contract exactly.
  - [ ] No websocket destination or manager references exist in this DTO file.

  **QA Scenarios**:
  ```
  Scenario: Outbound payload JSON matches chat send contract
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Encoding test asserts JSON includes only userId, username, content
    Evidence: .sisyphus/evidence/task-3-chat-send-dto-tests.txt

  Scenario: DTO stays transport-free
    Tool: Bash
    Steps: Run `grep -n "SocketManager\|topic/chat\|app/chat\|/chat" Projects/Modules/Data/Sources/RequestDTOs/Chat/ChatSendRequestDTO.swift`
    Expected: No matches returned
    Evidence: .sisyphus/evidence/task-3-chat-send-dto-grep.txt
  ```

  **Commit**: YES | Message: `feat(data): add outbound chat request dto` | Files: [`Projects/Modules/Data/Sources/RequestDTOs/Chat/ChatSendRequestDTO.swift`, `Projects/Modules/Data/Tests/**`]

- [x] 4. Add inbound chat response DTO

  **What to do**: Create `Projects/Modules/Data/Sources/DTOs/Chat/ChatMessageDTO.swift` conforming to `DTO` with fields `id`, `buyOrNotId`, `userId`, `username`, `content`, and `sentDateTime`. Model the inbound payload as a direct DTO payload, not a `CommonDTOBody<T>` wrapper, unless the websocket server actually wraps messages that way.
  **Must NOT do**: Do not name it `ChatMessageResponseDTO`. Do not parse `sentDateTime` into `Date` in this DTO. Do not assume a common envelope unless verified by actual socket payload.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: Single inbound wire-model task.
  - Skills: `[]` — No extra skill required.
  - Omitted: `swift-concurrency` — Not relevant.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [5, 6] | Blocked By: [1 for tests]

  **References**:
  - Pattern: `Projects/Modules/Data/Sources/DTOs/BuyOrNot/BuyOrNotDTO.swift:11-30` — feature-scoped inbound DTO naming and field declaration style
  - Anti-pattern boundary: `Projects/Modules/Data/Sources/DTOs/Common/CommonDTOBody.swift:11-32` — generic envelope exists, but should not be assumed for websocket chat unless server sends it

  **Acceptance Criteria**:
  - [ ] `ChatMessageDTO` conforms to `DTO` and decodes the full inbound message contract.
  - [ ] `sentDateTime` remains `String` in the DTO.
  - [ ] Decode tests cover the exact sample websocket payload.

  **QA Scenarios**:
  ```
  Scenario: Inbound chat payload decodes correctly
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Decoding test passes for sample payload with id, buyOrNotId, userId, username, content, sentDateTime
    Evidence: .sisyphus/evidence/task-4-chat-message-dto-tests.txt

  Scenario: DTO is not wrapped in unsupported common envelope
    Tool: Bash
    Steps: Run `grep -n "CommonDTOBody" Projects/Modules/Data/Sources/DTOs/Chat/ChatMessageDTO.swift`
    Expected: No matches returned unless the actual server payload is confirmed wrapped
    Evidence: .sisyphus/evidence/task-4-chat-message-dto-grep.txt
  ```

  **Commit**: YES | Message: `feat(data): add inbound chat message dto` | Files: [`Projects/Modules/Data/Sources/DTOs/Chat/ChatMessageDTO.swift`, `Projects/Modules/Data/Tests/**`]

- [x] 5. Add chat entity and mapper

  **What to do**: Create `Projects/Modules/Data/Sources/Entitys/Chat/ChatMessageEntity.swift` and `Projects/Modules/Data/Sources/Mappers/Chat/ChatMapper.swift`. The entity should expose app-facing fields mirroring the current verified contract, including `sentDateTime` as raw `String`. The mapper must convert `ChatMessageDTO` to `ChatMessageEntity`, and must also provide the outbound socket payload conversion from `ChatSendRequestDTO` into the `[Any]` / dictionary shape required by the thin transport consumer.
  **Must NOT do**: Do not parse `sentDateTime` into `Date` in this first pass. Do not place socket destination strings here. Do not leak raw `SocketManager.Event` into feature-facing entity APIs.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: This is the normalization seam between wire contracts and app-facing usage.
  - Skills: `[]` — No extra skill needed.
  - Omitted: `swift-concurrency` — Mapper/entity work is synchronous.

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: [6] | Blocked By: [3, 4]

  **References**:
  - Pattern: `Projects/Modules/Data/Sources/Mappers/UserMapper.swift` — mapper ownership belongs in Data mappers, not features
  - Pattern: `Projects/Modules/Data/Sources/DTOs/BuyOrNot/BuyOrNotDTO.swift:11-30` — DTO field style
  - Pattern: `Projects/Modules/Data/Sources/RequestDTOs/BuyOrNot/BuyOrNotVoteRequestDTO.swift:10-21` — outbound request DTO boundary

  **Acceptance Criteria**:
  - [ ] `ChatMessageEntity` exists under `Entitys/Chat` and is independent of `SocketManager`.
  - [ ] `ChatMapper` converts `ChatMessageDTO -> ChatMessageEntity` without date parsing assumptions.
  - [ ] `ChatMapper` exposes a deterministic outbound payload transform for `ChatSendRequestDTO`.

  **QA Scenarios**:
  ```
  Scenario: Mapper converts inbound DTO to app-facing entity
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Mapper tests prove field-by-field conversion from DTO to entity
    Evidence: .sisyphus/evidence/task-5-chat-mapper-tests.txt

  Scenario: Outbound payload transform stays contract-accurate
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Mapper/codec tests prove outbound payload dictionary contains exactly userId, username, content
    Evidence: .sisyphus/evidence/task-5-chat-outbound-payload-tests.txt
  ```

  **Commit**: YES | Message: `feat(data): add chat entity and mapper` | Files: [`Projects/Modules/Data/Sources/Entitys/Chat/ChatMessageEntity.swift`, `Projects/Modules/Data/Sources/Mappers/Chat/ChatMapper.swift`, `Projects/Modules/Data/Tests/**`]

- [x] 6. Add thin chat-specific SocketManager consumer

  **What to do**: Create `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift` as the only chat-protocol-aware consumer of `SocketManager`. It must accept a `ChatSocketEndpoint`, configure/connect using externally built `connectURL`, subscribe using `listen(event: endpoint.subscribeDestination)`, send using `emit(event: endpoint.sendDestination, items: ...)`, and delegate payload transformation to `ChatMapper`. It must also surface `observeLifecycle`/`observeErrors` pass-throughs or a narrowed chat-facing wrapper without modifying `SocketManager` responsibilities.
  **Must NOT do**: Do not add chat constants to `SocketManager.swift`. Do not implement STOMP frames, headers, ACK/NACK semantics, or room-join protocol logic inside `SocketManager`. If the backend rejects raw destination strings as event names, stop and report transport mismatch rather than force-fitting STOMP semantics into this task.

  **Recommended Agent Profile**:
  - Category: `deep` — Reason: This is the integration seam that must respect current actor-based transport, mapper boundaries, and protocol ownership rules.
  - Skills: [`swift-concurrency`] — Needed because `SocketManager` is actor-based and `AsyncStream`-driven.
  - Omitted: [`swiftui-expert-skill`] — No UI work here.

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: [Final Verification] | Blocked By: [2, 3, 4, 5]

  **References**:
  - Pattern: `Projects/Modules/Data/Sources/Support/SocketManager.swift:17-20` — actor-based transport manager boundary
  - Pattern: `Projects/Modules/Data/Sources/Support/SocketManager.swift:124-149` — external configuration injection
  - Pattern: `Projects/Modules/Data/Sources/Support/SocketManager.swift:185-236` — generic emit / emitWithAck API surface
  - Pattern: `Projects/Modules/Data/Sources/Support/SocketManager.swift:238-322` — listen / observe event streams

  **Acceptance Criteria**:
  - [ ] `ChatSocketClient` is the only file that knows chat endpoint strings and `SocketManager` usage together.
  - [ ] `SocketManager.swift` remains transport-generic after integration.
  - [ ] Chat send/receive flow compiles through endpoint builder + mapper + socket manager.
  - [ ] If transport mismatch is encountered, implementation stops with explicit error/reporting rather than embedding STOMP logic into `SocketManager`.

  **QA Scenarios**:
  ```
  Scenario: Chat socket seam compiles with generic manager preserved
    Tool: Bash
    Steps: Run `tuist build Data`
    Expected: Data builds successfully with ChatSocketClient using SocketManager without modifying manager responsibilities
    Evidence: .sisyphus/evidence/task-6-chat-socket-client-build.txt

  Scenario: SocketManager remains protocol-free
    Tool: Bash
    Steps: Run `grep -n "topic/chat\|app/chat\|ChatSendRequestDTO\|ChatMessageDTO" Projects/Modules/Data/Sources/Support/SocketManager.swift`
    Expected: No matches returned from SocketManager.swift
    Evidence: .sisyphus/evidence/task-6-socket-manager-boundary.txt
  ```

  **Commit**: YES | Message: `feat(data): add chat socket client seam` | Files: [`Projects/Modules/Data/Sources/Support/ChatSocketClient.swift`, `Projects/Modules/Data/Sources/SocketEndpoints/ChatSocketEndpoint.swift`, `Projects/Modules/Data/Sources/Mappers/Chat/ChatMapper.swift`, `Projects/Modules/Data/Tests/**`]

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [ ] F1. Plan Compliance Audit — oracle
- [ ] F2. Code Quality Review — unspecified-high
- [ ] F3. Real Manual QA — unspecified-high (+ websocket manual smoke verification if a compatible backend is available)
- [ ] F4. Scope Fidelity Check — deep

## Commit Strategy
- Commit after each numbered task.
- Keep transport-boundary changes isolated from model-definition changes.
- Never combine `SocketManager` edits with chat contract artifacts in one commit unless a compile fix is unavoidable.
- If task 6 reveals true STOMP incompatibility, do not continue layering hacks into the same commit; stop with a dedicated transport-mismatch report.

## Success Criteria
- Chat websocket contract artifacts have one obvious home each: endpoint builder, outbound request DTO, inbound DTO, entity, mapper, transport consumer.
- `SocketManager` remains protocol-free and URL-free.
- Data tests prove endpoint formatting, outbound encoding, inbound decoding, and mapper behavior.
- The implementation path is ready for `/start-work` without requiring new judgment calls.
