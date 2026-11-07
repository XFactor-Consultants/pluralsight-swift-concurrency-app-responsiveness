# TaskFlow: Swift Concurrency and App Responsiveness

Starting point for the Pluralsight course *Swift Concurrency and App Responsiveness*.

TaskFlow is a SwiftUI team task app. This version is intentionally imperfect: it contains the concurrency mistakes the course teaches you to find and fix.

## Starting state

- Xcode 26.x, iOS 26.5 deployment target, SwiftData (History archive only).
- Build settings: Default Actor Isolation = MainActor, Approachable Concurrency on, Swift language mode 5.
- **Task**: 5,000 generated tasks plus a few hand-written ones.
- **Activity tab**: `ActivityStore` awaits three independent requests one after another, wraps them in `try?`, and is triggered twice per visit (`.task` and `.onAppear`).
- **Sync**: `SyncEngine` simulates a background sync every 10 seconds. It sorts 1.5 million numbers, and under the project's MainActor default it runs on the main thread. It is test scaffolding.
- **Sync banner**: `SyncBanner` uses a Combine timer and a counter.
- **Search index**: built synchronously on the main actor, at launch and on every return to the foreground.
- **Memory warning**: `RootView` clears the avatar cache using a Combine notification publisher.

## Files

| File | Role |
|---|---|
| `TaskFlowApp`, `RootView` | Entry point, tab bar, launch work |
| `TaskListView`, `TaskDetailView`, `SettingsView` | Screens |
| `TasksStore`, `Models` | Tasks and teammates |
| `ActivityStore`, `ActivityView`, `FeedCache` | Activity feed |
| `HistoryView`, `ArchivedTask` | History tab and the archived records |
| `SearchIndex` | Text index of every task |
| `SyncEngine`, `SyncBanner` | Simulated sync and its banner |
| `TaskDetailModel` | Model behind one open task |

## Branches

One before and one after branch per module (to be added).
