# Chat Socket Disconnect Recovery Plan

## TL;DR
> **Summary**: Fix the chat popup issue by addressing the actual transport failure path, not just the popup text. The current client negotiates STOMP with `heart-beat: 0,0`, has no WebSocket keepalive, and has no automatic reconnect path, so an idle socket can die in the foreground and later surface the raw system error `Socket is not connected` to users. The plan is to add transport-level keepalive and reconnect behavior in `SocketManager`, then update `ChattingViewFeature` so reconnecting is handled as a recoverable state instead of an immediate alert.
> **Deliverables**:
> - Transport reliability changes in `Projects/Modules/Data/Sources/Support/SocketManager.swift`
> - Chat socket lifecycle adjustments in `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift`
> - User-facing error and reconnect flow updates in `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift`
> - Optional reconnect UX tweak in `Projects/Modules/Features/Common/Sources/ChatView/ChattingView.swift`
> - Regression and lifecycle verification for idle, reconnect, foreground return, and stale-send scenarios
> **Effort**: Medium
> **Parallel**: YES - 3 waves
> **Critical Path**: T1/T2 → T3 → T4/T5

## Context
### Original Request
- A plan is needed for intermittent chat socket disconnection.
- While connected to chat, after a few minutes, the popup appears with:
  - `The operation couldn't be completed. Socket is not conneted`
- The request explicitly asks for:
  - cause analysis
  - a solution direction if one exists
  - reflecting that analysis in the saved plan

### Repository Facts Confirmed During Investigation
- `Projects/Modules/Data/Sources/Support/SocketManager.swift`
  - owns `URLSessionWebSocketTask` transport and STOMP framing.
  - sends CONNECT with `"heart-beat": "0,0"`.
  - has no visible `sendPing`, `pong`, heartbeat scheduler, or reconnect scheduler.
  - emits `.socketError(message: error.localizedDescription)` on send/receive failures.
- `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift`
  - wraps `SocketManager` for chat-specific connect/listen/send.
  - `connect(endpoint:)` waits for `.connected` or `.disconnected`, with a 5-second timeout race.
  - `sendMessage(_:)` forwards directly to `socketManager.emit(...)`.
- `Projects/Modules/Data/Sources/Support/ChatRepository.swift`
  - exposes `connectSocket`, `disconnectSocket`, `observeSocketErrors`, `incomingMessages`, `sendMessage`.
- `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift`
  - connects socket on appear.
  - reconnects only on `willEnterForeground`.
  - maps `.socketError(message)` to the raw message when non-empty.
  - pushes that message into `showErrorMessage`.
- `Projects/Modules/Features/Common/Sources/ChatView/ChattingView.swift`
  - presents `showErrorMessage` as a popup alert.

### Confirmed Root-Cause Hypothesis
- The foreground chat session can stay open long enough for the underlying socket to become stale or be closed by the server/network.
- Because the client negotiated `heart-beat: 0,0`, it does not actively maintain the STOMP session.
- Because the transport layer has no ping/keepalive and no reconnect behavior, the next send/receive hits a dead socket.
- The resulting transport error bubbles up as a raw localized string and becomes a popup.

### Important Constraint / Unknown
- The exact reconnect and heartbeat policy expected by the backend STOMP server is not encoded in the app today.
- Before finalizing implementation defaults, verify the backend server’s heartbeat contract and idle-timeout behavior.

## Work Objectives
### Core Objective
Make chat resilient to idle-time socket drops while the user remains on the chat screen, and prevent raw transport errors from surfacing directly to the UI.

### Deliverables
- Keepalive and reconnect lifecycle in `SocketManager`
- Clear reconnect ownership between `SocketManager` and `ChatSocketClient`
- Reconnect-aware chat reducer flow in `ChattingViewFeature`
- User-friendly Korean error handling for permanent failure cases
- Verification coverage for idle disconnect and lifecycle recovery

### Definition of Done (verifiable conditions with commands)
- `tuist build Data` succeeds after transport changes.
- `tuist build FeatureCommon` succeeds after reducer/view changes.
- `tuist test Data` covers STOMP frame / socket lifecycle regressions relevant to the changes.
- `tuist test FeatureCommon` covers reconnect/error handling behavior if a FeatureCommon test target exists; if not, add or document the nearest executable validation path.
- `grep -n 'heart-beat' Projects/Modules/Data/Sources/Support/SocketManager.swift` no longer shows `0,0` as the final negotiated client request.
- `grep -n 'Socket is not connected\|Socket is not conneted' Projects/Modules/Features/Common/Sources/ChatView/*.swift` returns no raw user-facing fallback strings.

### Must Have
- Transport fix first, popup copy second.
- Reconnect must distinguish unexpected disconnect from user-initiated disconnect.
- UI must treat transient reconnect as recoverable state, not immediate fatal alert.
- Reconnect success path must restore subscriptions and continue message flow.
- Foreground re-entry flow must remain compatible with the existing `willEnterForeground` behavior.

### Must NOT Have
- No raw English transport error popup to users as final UX.
- No fake “fixed” state that only changes the alert text while leaving transport unreliable.
- No new chat protocol strings leaked into unrelated layers.
- No destructive socket reconnect loop that keeps retrying after explicit user navigation away.

## Verification Strategy
> ZERO HUMAN INTERVENTION where practical — agent-executed verification first, then focused manual runtime validation for long-idle behavior.
- Data-layer checks: transport/reconnect unit coverage, build pass
- Feature-layer checks: reducer-level reconnect/error mapping coverage, build pass
- Runtime checks: idle foreground wait, foreground return, stale send after disconnect, retry exhaustion path

## Execution Strategy
### Parallel Execution Waves
Wave 1: transport defaults + user-facing error policy
- T1 transport keepalive / heartbeat policy
- T2 user-facing error mapping and reconnect state policy

Wave 2: reconnect behavior
- T3 automatic reconnect and reconnect lifecycle propagation

Wave 3: integration verification
- T4 feature-layer reconnect restoration flow
- T5 validation and regression checks

### Dependency Matrix
- T1 blocks T3.
- T2 blocks T4 user-facing behavior.
- T3 blocks T4 and T5.
- T4 blocks T5.

## TODOs
> Implementation + test stay coupled.

- [ ] 1. Add socket keepalive and heartbeat negotiation policy

  **What to do**: Update `Projects/Modules/Data/Sources/Support/SocketManager.swift` so the transport no longer advertises `heart-beat: 0,0` by default. Add the minimum reliable keepalive behavior needed for an idle foreground chat session, using STOMP heartbeat negotiation and/or `URLSessionWebSocketTask` ping support where appropriate. Ensure any new background task or timer is cancelled on disconnect and teardown.
  **Must NOT do**: Do not ship a reconnect loop before the connection-health policy is defined. Do not assume backend heartbeat defaults without capturing them as verification requirements.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — transport-layer lifecycle change inside an actor
  - Skills: [`swift-concurrency`]

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [3] | Blocked By: []

  **References**:
  - `Projects/Modules/Data/Sources/Support/SocketManager.swift:161-194` — connect setup and CONNECT headers
  - `Projects/Modules/Data/Sources/Support/SocketManager.swift:328-353` — receive loop failure path
  - `Projects/Modules/Data/Sources/Support/SocketManager.swift:419-441` — teardown behavior

  **Acceptance Criteria**:
  - [ ] Client no longer advertises `heart-beat: 0,0` as the final behavior.
  - [ ] Keepalive/heartbeat work is active only while connected.
  - [ ] Teardown cancels any keepalive work cleanly.
  - [ ] Build and relevant tests pass.

  **QA Scenarios**:
  ```
  Scenario: SocketManager no longer requests STOMP heartbeat 0,0
    Tool: Bash
    Steps: Run `grep -n 'heart-beat' Projects/Modules/Data/Sources/Support/SocketManager.swift`
    Expected: Output shows the heartbeat header exists, and the effective client request is no longer `0,0`

  Scenario: Data module still builds after transport changes
    Tool: Bash
    Steps: Run `tuist build Data`
    Expected: Build succeeds with exit code 0

  Scenario: Existing and new transport tests still pass
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Data tests pass, including the STOMP/socket lifecycle tests relevant to the transport change
  ```

- [ ] 2. Stop surfacing raw socket transport strings to the popup

  **What to do**: Update `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift` so `.socketError(message)` does not expose raw localized transport messages directly to users. Introduce reconnect-aware state and a user-facing message policy that distinguishes transient reconnectable errors from terminal failure.
  **Must NOT do**: Do not hide terminal failures entirely. Do not leave the current raw-message passthrough in place.

  **Recommended Agent Profile**:
  - Category: `unspecified-low`
  - Skills: [`swiftui-expert-skill`]

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [4] | Blocked By: []

  **References**:
  - `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift:132-136` — socket error stream
  - `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift:218-224` — popup state flow
  - `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift:282-293` — current error mapping
  - `Projects/Modules/Features/Common/Sources/ChatView/ChattingView.swift:43-48` — popup presentation

  **Acceptance Criteria**:
  - [ ] Raw English socket transport errors are not shown directly to users.
  - [ ] Reconnectable failures can be suppressed or softened while retry is in progress.
  - [ ] Terminal failures still produce a clear Korean message.

  **QA Scenarios**:
  ```
  Scenario: Raw transport string is no longer used as the direct popup message
    Tool: Bash
    Steps: Run `grep -n 'Socket is not connected\|Socket is not conneted' Projects/Modules/Features/Common/Sources/ChatView/*.swift`
    Expected: No raw user-facing fallback string remains in chat feature/view files

  Scenario: FeatureCommon still builds after message-policy changes
    Tool: Bash
    Steps: Run `tuist build FeatureCommon`
    Expected: Build succeeds with exit code 0

  Scenario: Reconnect-aware error mapping is validated by tests when available
    Tool: Bash
    Steps: Run `tuist test FeatureCommon`
    Expected: FeatureCommon tests pass, or if no test target exists yet, the implementation task must add/define the nearest executable reducer-level verification path before completion
  ```

- [ ] 3. Implement unexpected-disconnect reconnect flow

  **What to do**: Extend `Projects/Modules/Data/Sources/Support/SocketManager.swift` and, if needed, `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift` so unexpected disconnects trigger a bounded reconnect flow with lifecycle events that higher layers can observe. Keep explicit user disconnect separate so navigating away from chat does not re-open the socket.
  **Must NOT do**: Do not introduce infinite reconnect churn. Do not reconnect after `disconnectSocket()` was intentionally triggered by screen exit.

  **Recommended Agent Profile**:
  - Category: `deep`
  - Skills: [`swift-concurrency`]

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: [4, 5] | Blocked By: [1]

  **References**:
  - `Projects/Modules/Data/Sources/Support/SocketManager.swift:101-107` — lifecycle enum already hints at reconnect semantics
  - `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift:35-65` — chat connect handshake result flow
  - `Projects/Modules/Data/Sources/Support/ChatSocketClient.swift:124-129` — available lifecycle/error streams

  **Acceptance Criteria**:
  - [ ] Unexpected disconnect triggers bounded reconnect attempts.
  - [ ] Explicit user disconnect does not trigger reconnect.
  - [ ] Successful reconnect restores active subscription flow.
  - [ ] Reconnect lifecycle is observable by upper layers.

  **QA Scenarios**:
  ```
  Scenario: Data module builds with reconnect logic
    Tool: Bash
    Steps: Run `tuist build Data`
    Expected: Build succeeds with exit code 0

  Scenario: Reconnect-related lifecycle API is present in transport/chat seam
    Tool: Bash
    Steps: Run `grep -n 'reconnect\|reconnectAttempt\|observeLifecycle' Projects/Modules/Data/Sources/Support/SocketManager.swift Projects/Modules/Data/Sources/Support/ChatSocketClient.swift Projects/Modules/Data/Sources/Support/ChatRepository.swift`
    Expected: Output shows bounded reconnect lifecycle support is wired through the layers needed by the feature

  Scenario: Reconnect behavior is covered by executable tests
    Tool: Bash
    Steps: Run `tuist test Data`
    Expected: Data tests pass and include coverage for unexpected disconnect vs explicit disconnect behavior
  ```

- [ ] 4. Make the chat feature reconnect-aware

  **What to do**: Update `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift` so the reducer can react to reconnect lifecycle transitions, avoid duplicate streams during reconnect, and restore chat state after reconnection. Confirm whether `ChattingView.swift` needs a subtle reconnect indicator instead of a blocking popup for transient cases.
  **Must NOT do**: Do not leave reconnect completely invisible if the user experiences a long outage. Do not duplicate incoming-message subscriptions after reconnect.

  **Recommended Agent Profile**:
  - Category: `unspecified-high`
  - Skills: [`swiftui-expert-skill`, `swift-concurrency`]

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: [5] | Blocked By: [2, 3]

  **References**:
  - `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift:104-139` — initial connect and stream startup
  - `Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift:149-186` — foreground reconnect path
  - `Projects/Modules/Data/Sources/Support/ChatRepository.swift:83-115` — repository seam used by the feature

  **Acceptance Criteria**:
  - [ ] Reducer handles reconnecting/reconnected/permanent-failure states explicitly.
  - [ ] No duplicate message stream registration after reconnect.
  - [ ] Existing foreground return behavior still works.

  **QA Scenarios**:
  ```
  Scenario: Feature layer builds after reconnect-state wiring
    Tool: Bash
    Steps: Run `tuist build FeatureCommon`
    Expected: Build succeeds with exit code 0

  Scenario: Reconnect state handling exists in the reducer
    Tool: Bash
    Steps: Run `grep -n 'reconnecting\|reconnected\|permanent\|observeSocketLifecycle\|willEnterForeground' Projects/Modules/Features/Common/Sources/ChatView/ChattingViewFeature.swift`
    Expected: Output shows explicit reconnect-state handling without removing the foreground recovery path

  Scenario: Reducer/runtime logic avoids duplicate stream wiring
    Tool: Bash
    Steps: Run `tuist test FeatureCommon`
    Expected: FeatureCommon tests pass and cover reconnect-state transitions or duplicate-stream prevention; if no test target exists, the implementation task must add one or document an equivalent executable verification before completion
  ```

- [ ] 5. Verify idle disconnect recovery and failure UX

  **What to do**: Validate the fix set with build/test execution plus targeted runtime checks for long-idle foreground chat, app foreground return, stale send after disconnect, and retry exhaustion. If backend heartbeat settings are unclear, capture that verification as required evidence before considering the issue fully closed.
  **Must NOT do**: Do not declare success from compile-only validation. Do not skip the idle-time scenario that triggered the original bug report.

  **Recommended Agent Profile**:
  - Category: `deep`
  - Skills: [`swift-concurrency`, `swiftui-expert-skill`]

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: [] | Blocked By: [3, 4]

  **Acceptance Criteria**:
  - [ ] `tuist build Data` succeeds.
  - [ ] `tuist build FeatureCommon` succeeds.
  - [ ] Relevant tests succeed.
  - [ ] Idle foreground chat no longer fails with a raw transport popup.
  - [ ] Permanent disconnect path produces intentional user-facing messaging.

  **QA Scenarios**:
  ```
  Scenario: Transport and feature modules both compile after the full fix
    Tool: Bash
    Steps:
      1. Run `tuist build Data`
      2. Run `tuist build FeatureCommon`
    Expected: Both builds succeed with exit code 0

  Scenario: Automated tests pass across the changed layers
    Tool: Bash
    Steps:
      1. Run `tuist test Data`
      2. Run `tuist test FeatureCommon`
    Expected: Relevant tests pass; if FeatureCommon lacks a test target, that gap must be resolved or an equivalent executable verification path must be added before completion

  Scenario: Long-idle foreground chat no longer surfaces the raw socket popup
    Tool: Simulator / Manual runtime verification
    Steps:
      1. Launch the app and enter a chat room on the simulator or device
      2. Leave the chat screen open in the foreground for longer than the currently observed failure window
      3. If possible, inspect logs while the socket remains idle
    Expected: No raw `Socket is not connected` popup appears; either the connection stays healthy or reconnect happens without a raw transport alert

  Scenario: Foreground return still recovers chat correctly
    Tool: Simulator / Manual runtime verification
    Steps:
      1. Enter a chat room
      2. Send the app to background
      3. Return the app to foreground
      4. Observe whether history reloads and live chat resumes
    Expected: Existing `willEnterForeground` flow still restores chat without duplicate streams or raw transport popup

  Scenario: Stale send after a forced disconnect is handled intentionally
    Tool: Simulator / Manual runtime verification
    Steps:
      1. Enter a chat room
      2. Force a disconnect condition (for example, disable network or stop the backend socket endpoint)
      3. Attempt to send a message while the connection is stale
    Expected: The app either reconnects and recovers, or shows a planned Korean failure message rather than a raw transport string

  Scenario: Retry exhaustion produces terminal UX, not silent failure
    Tool: Simulator / Manual runtime verification
    Steps:
      1. Keep the backend/socket unavailable long enough to exhaust retry policy
      2. Observe the final user-facing result
    Expected: The app stops retrying at the configured bound and shows an intentional final error state/message

  Scenario: Backend heartbeat contract is confirmed before final signoff
    Tool: Project docs / backend confirmation note
    Steps:
      1. Confirm the STOMP heartbeat interval and idle-timeout policy from backend docs, code, or the owning backend engineer
      2. Record the confirmed contract alongside implementation evidence
    Expected: Final implementation defaults are aligned with the actual backend contract instead of guesswork
  ```

## Recommended Implementation Order
1. Define keepalive / heartbeat behavior in `SocketManager`.
2. Remove raw socket error passthrough from `ChattingViewFeature`.
3. Add bounded reconnect for unexpected disconnects.
4. Make the feature layer reconnect-aware and avoid duplicate stream startup.
5. Run build/test/runtime verification, including backend contract confirmation.

## Risks and Explicit Verification Items
- Backend STOMP server may expect a specific heartbeat interval; confirm before hard-coding the final value.
- `URLSessionWebSocketTask` ping behavior and STOMP heartbeat behavior should not conflict; validate one ownership model rather than stacking duplicate mechanisms blindly.
- Reconnect timing must not interfere with the existing `willEnterForeground` reconnect path.
- If the server intentionally closes idle sessions and requires re-auth or re-subscription rules, capture that explicitly during verification.

## Success Criteria
- The user can remain in chat for several minutes without seeing the raw `Socket is not connected` popup.
- If the socket drops unexpectedly, the client recovers automatically in the common case.
- If recovery fails, the UI shows an intentional Korean failure message instead of a raw system transport string.
- The chat feature remains stable across foreground return and screen dismissal.
