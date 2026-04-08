# Project Notes

## Tuist

- To regenerate the Xcode project, run: `mise run generate`
- Always run `mise run generate` after structural changes to the project (adding/removing targets, files, dependencies in Project.swift)

## Tech Stack

- Swift 6.0 strict concurrency, iOS 26.0
- SwiftUI only (no UIKit)
- Zero external dependencies — only Apple frameworks
- Swift Testing framework (`@Suite`, `@Test`, `#expect`) — not XCTest

## Architecture

- MVVM with Swift Actors and AsyncStreams
- Unidirectional data flow: View → Action → ViewModel → Actor → AsyncStream → ViewModel → View
- `@Observable` for ViewModels, `@ObservationIgnored` for dependencies — no Combine
- DI via `Dependencies` structs with `static let live` factory + SwiftUI `EnvironmentKey`

## Code Style

- Always add file headers to new Swift files following the existing pattern:
  ```
  //
  //  FileName.swift
  //  TargetName
  //
  //  Created by Alex Shubin on DD.MM.YY.
  //  Copyright © YYYY Alex Shubin. All rights reserved.
  //
  ```
- Avoid using `any` with protocol types when it's not required. Prefer `let sut: MetronomeViewModelType` over `let sut: any MetronomeViewModelType`.

## Naming Conventions

- `*Type` suffix for protocols (`MetronomeType`, `MetronomeEngineType`)
- `*ViewState` for UI state structs, `*Action` for view model action enums
- Features organized as `Features/FeatureName/` with View, ViewModel, and optional `Subviews/`

## Project Structure

- Each Tuist project follows the naming convention: `Feature`, `FeatureTests`, `FeatureTestSupport` (when needed). For example: `MetronomeEngine`, `MetronomeEngineTests`, `MetronomeEngineTestSupport`.

## Testing

- Never use `Task.sleep` in tests. Design production code to be testable without timing dependencies — use `async` APIs that tests can `await` directly, or `withCheckedContinuation` + `withObservationTracking` for stream-based state propagation.
- Always declare the SUT using the protocol type (e.g., `let sut: MetronomeViewModelType`), not the concrete type. Tests should exercise the object through its public interface only.
- Mocks record calls via a `Call` enum with associated values matching method signatures.
- Stubbed properties control mock return values.
- Public mocks live in `TestSupport/`, internal mocks in `Tests/Mocks/`.
- Mock actors expose `sendState()`/`sendTick()` helpers for pushing state in tests.

