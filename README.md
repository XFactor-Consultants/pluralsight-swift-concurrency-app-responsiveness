# TaskFlow: Swift Concurrency and App Responsiveness

Source code for the Pluralsight course *Swift Concurrency and App Responsiveness* course. 

Async code is easy to write and hard to make safe. This course takes a working SwiftUI app that has the usual concurrency mistakes built in, and walks through finding and fixing them, one at a time, until the app is responsive, correct, and compiles cleanly in Swift 6 language mode.

## Who this course is for

You should be comfortable with SwiftUI views and with Observation (`@Observable`). You should also have a general idea of what asynchronous work means. You don't need any experience with `async`/`await`; the course starts there.

## The app

TaskFlow is a small SwiftUI team task app with four tabs:

| Tab | What it shows |
|---|---|
| **Tasks** | A list of 5,000 generated tasks plus a few hand-written ones, with a sync banner at the bottom |
| **Activity** | Teammates' updates, mentions, and related items. The data is simulated with short delays, so the course stays on concurrency and not networking |
| **History** | Archived records for a selected teammate |
| **Settings** | Workspace information, the team list, and (from Module 4) a Diagnostics section |

The app starts out intentionally imperfect. It blocks its own interface, runs work for screens nobody is looking at, and races on shared state. Each module fixes a different set of those problems.

`SyncEngine` is test scaffolding. It stands in for a real background sync by doing real work on a schedule: it sorts 1.5 million numbers every ten seconds. There is no server.

## Requirements and setup

- Xcode 26.x, with an iOS 26.5 deployment target.
- SwiftData is used only for the History archive.
- The starting build settings are Default Actor Isolation = MainActor, Approachable Concurrency on, and Swift Language Mode 5.

Open `TaskFlow.xcodeproj`, choose an iPhone simulator, and run. Files you add to the `TaskFlow` folder are added to the target automatically.

## Files added during the course

| File | Added in | Role |
|---|---|---|
| `AvatarCache` | Module 2 | An actor that caches avatars and joins duplicate loads |
| `TaskMonitor`, `RaceCounter`, `ReportLoader` | Module 4 | Support code for the diagnostics scenarios |
| `DiagnosticsView`, `RaceView`, `InversionView`, `LeakView` | Module 4 | The three diagnostics screens |

## Branches

`main` is the starting point. There is one branch for each module, `m1` through `m4`, holding the code as it stands at the end of that module. To follow along, start from `main` and apply the changes shown in each clip, or check out a module's branch to compare against yours.

---

## Module 1: Building Asynchronous Workflows with Structured Concurrency and MainActor Isolation

### Clip 1: Writing async/await Code and Understanding Task Hierarchies

**Outline:** Write async functions and create child tasks, seeing how structured concurrency organizes work into a parent-child hierarchy, and how completion, cancellation, and errors flow through it.

**What we do:** Read `ActivityStore.load()` to see each `await` as a suspension point, then change its three sequential requests to `async let` child tasks.

**Result:** The load drops from about 1.15 s to about 0.6 s in Instruments.

### Clip 2: Managing UI Responsiveness with MainActor Isolation

**Outline:** Identify where UI state updates must happen on the MainActor, and refactor a scenario where they don't into MainActor-isolated code.

**What we do:** A profile shows the 389 ms sort in `SyncEngine.performSync()` running on the main thread, because the project defaults to the main actor. We run it in a detached task as a `nonisolated static` function, and hand the result back through a main-actor `apply` with `await`.

**Result:** The list scrolls smoothly through every sync.

### Clip 3: Applying Cooperative Cancellation to Lifecycle-Aware Tasks

**Outline:** Tie task lifecycles to view lifetimes and apply cooperative cancellation, refactoring a leaked task and a misused `Task.sleep` into cancellable, lifecycle-aware tasks.

**What we do:** Leaving the Activity screen early doesn't stop its loads. We add a `Task.isCancelled` check, because `try?` swallows the sleep's cancellation, and delete the unowned `Task` in `onAppear`.

**Result:** The load counter reads one per visit instead of two.

---

## Module 2: Protecting Shared State and Coordinating Concurrent Work

### Clip 1: Isolating Shared Mutable State with Actors

**Outline:** Convert a shared mutable value accessed from several tasks into an actor, and see how isolation serializes access and prevents data races.

**What we do:** Create `AvatarCache` as a class and hit it from two thousand tasks, which crashes in Swift 5 mode. Changing it to an actor fixes the race. We then handle reentrancy by recording an in-flight task per ID, so duplicate callers share one load.

**Result:** A crash, then a correct count, then one load instead of two.

### Clip 2: Adopting Sendable Types and Swift 6 Concurrency Safety

**Outline:** Mark types `Sendable` and work through the compiler errors that appear when a non-Sendable type crosses an isolation boundary.

**What we do:** Move the search index rebuild off the main thread, switch the project to Swift 6, and mark `SearchIndex`, `TaskItem`, and `Teammate` as `nonisolated` and `Sendable`. We then revisit the Clip 1 race, which Swift 6 refuses to build.

**Result:** The app looks the same, but data crossing a boundary is now checked at compile time.

### Clip 3: Coordinating Parallel Work with async let and Task Groups

**Outline:** Run independent operations with `async let`, coordinate a variable number with a task group, and choose between them by whether the count is fixed or dynamic.

**What we do:** Revisit the three fixed requests, then replace `warmAvatarCache` with `loadAvatars`, a task group with one child per teammate. Each child returns its ID with its image, because results arrive in finish order.

**Result:** The list appears immediately and avatars load in the background.

---

## Module 3: Consuming Async Data Streams and Applying Concurrency in SwiftUI

### Clip 1: Producing and Consuming AsyncSequence Data Streams

**Outline:** Iterate an `AsyncSequence` with `for await`, then build a simple stream of your own.

**What we do:** Replace the Combine memory-warning handler with a `for await` loop over notifications. Add an `AsyncStream<Date>` to `SyncEngine`, yielded from `apply`, and rewrite `SyncBanner` to show the real time of the last sync.

**Result:** The banner starts at "Waiting for first sync" and updates every ten seconds.

### Clip 2: Applying Task Modifiers and Lifecycle-Aware Tasks in SwiftUI

**Outline:** Attach async work with `.task`, see it start and cancel with the view, and compare it to manually managed tasks that leave orphaned work.

**What we do:** Compare `ActivityView`'s `.task` with `SyncEngine`'s manually managed task. Replace History's `onAppear` and `onChange` with a single `.task(id: selectedName)`.

**Result:** The rows behave as before, with one trigger instead of two.

### Clip 3: Managing Observable Async State and MainActor Correctness in SwiftUI

**Outline:** Update `@Observable` state from an async task inside a SwiftUI view, keeping updates isolated to the MainActor.

**What we do:** Review where the app already updates state from async work (`apply`, `loadAvatars`, `ActivityStore.load()`), then add `.refreshable` to the Activity list.

**Result:** Pulling the list shows a spinner, then the updated items.

---

## Module 4: Diagnosing Concurrency Issues and Migrating to Swift 6

For this module the project is deliberately set back to Swift 5 with minimal concurrency checking, so the race compiles. The last clip migrates it forward again. Module 4 adds a **Diagnostics** section to the Settings tab with three screens and a counter of running background tasks.

### Clip 1: Diagnosing Race Conditions, Priority Inversion, and Task Leaks

**Outline:** Examine a sample app with a race, a priority inversion, and a leaked task, using each symptom to recognize the underlying mistake before fixing it.

**What we do:** Use each screen, read the symptom, then find the cause in the code.

| Screen | Symptom | Cause |
|---|---|---|
| **Race** | The total comes up short by a different amount each run | `RaceCounter.increment()` is an unprotected read-modify-write on a class |
| **Inversion** | The screen freezes with an idle CPU, and the Thread Performance Checker flags it | `ReportLoader.loadBlocking()` stops the main thread with a semaphore |
| **Leak** | The task counter goes 1, 2, 3 as you re-enter the screen | `LeakView` starts a detached task from `onAppear` that never stops |

### Clip 2: Correcting Improper Actor Isolation and Unstructured Concurrency

**Outline:** Refactor misused unstructured concurrency and improper isolation into structured, actor-isolated equivalents.

**What we do:** In `LeakView`, replace the detached task with a `.task` modifier that checks for cancellation. Delete `loadBlocking`, and have the button await `ReportLoader.generate()` in a `Task`.

**Result:** The counter returns to zero, and the Inversion screen stays scrollable.

### Clip 3: Migrating Apps to Swift 6 Concurrency Using Xcode Diagnostics

**Outline:** Run a pre-migration app under Thread Sanitizer to surface a race, enable complete checking and Swift 6 mode, resolve the diagnostics with an actor, and verify with a final TSan run.

**What we do:**
1. Turn on Thread Sanitizer and run the Race screen. It reports the race in `increment`.
2. Set Strict Concurrency Checking to Complete. The same problem appears as a warning.
3. Set Swift Language Mode to 6. The warning becomes an error.
4. Change `RaceCounter` to an actor and add `await` at the two call sites in `RaceView`.
5. Run again under Thread Sanitizer.

**Result:** The total is exactly 2,000 every time, and Thread Sanitizer reports nothing.

---

## Where the course leaves you

You started with an app that blocked its own interface, ran work for screens nobody was looking at, and raced on shared state. You now have the tools to fix each of those: structured tasks, cooperative cancellation, MainActor isolation, actors and Sendable types, async streams, and the compiler and sanitizer to check your work. The next step is to apply these to your own code.

## Troubleshooting

**The race doesn't compile, or Xcode says "Passing closure as a 'sending' parameter risks causing data races."**
The target is in Swift 6 mode or strict checking is on. For the Module 2 Clip 1 and Module 4 demos, set Swift Language Mode to 5 and Strict Concurrency Checking to Minimal on the **TaskFlow target**, then clean the build folder (Cmd+Shift+K).

**I can't find Swift Language Mode or Strict Concurrency Checking.**
Select the project in the navigator, then the **TaskFlow target** (not the project), then Build Settings. Choose **All** and **Combined**, and search `language` or `strict concurrency`. The raw name for the language setting is `SWIFT_VERSION`.

**I can't find Thread Sanitizer.**
It's in the scheme, not the build settings: click the scheme name in the toolbar, choose Edit Scheme, select Run, open Diagnostics, and check Thread Sanitizer. Turn it off for Module 4 Clip 1, where it would stop the app on the Race screen.

**The Race total comes out exactly 2,000 before the fix.**
The tasks didn't happen to collide. Raise the `2_000` loop count in `RaceView` to something like `20_000` and update the "of 2000" text to match.

**The Thread Performance Checker doesn't flag the Inversion screen.**
Make sure it's checked in the scheme's Diagnostics tab. If the Simulator still shows nothing, run on a device.

**Thread Sanitizer still reports a race after the actor change.**
Stop the app, clean the build folder, and clear the Issue navigator before running again, since a stale report or build is the usual cause. Confirm that `RaceCounter.swift` says `actor RaceCounter` and that both call sites in `RaceView` use `await`.

**Avatars don't appear in the task list.**
The row view must read `tasksStore.avatarCache`, and `avatarCache` must not be marked `@ObservationIgnored`. Otherwise nothing redraws when the avatars arrive.

**"Closure containing control flow statement cannot be used with result builder 'ViewBuilder'."**
A modifier's closure ended up outside the modifier chain, usually a leftover or missing brace after deleting a block. Check that `.task { ... }` sits directly under the previous modifier.

**Xcode's autocomplete mangles typed code.**
Turn off Xcode, Settings, Text Editing, Code Completion, "Suggest completions while typing", and turn off "Automatically insert closing braces."

**Timings differ from the videos.**
The figures come from one machine. Yours will vary, but the before and after comparison should hold.

