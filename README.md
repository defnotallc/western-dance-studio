# Western Dance Studio

## Apple Developer

- **Team ID:** `XXY79DCD4H`
- **Bundle ID:** `com.defnota.WesternDanceStudio`
- Set on all four build configurations (app Debug/Release, Tests Debug/Release) in
  `Western Dance Studio.xcodeproj/project.pbxproj` via `DEVELOPMENT_TEAM`.

## Entitlements

`WesternDanceStudio/WesternDanceStudio.entitlements` (wired via `CODE_SIGN_ENTITLEMENTS`
on the app target's Debug/Release configs):

- **iCloud Key-value storage** (`com.apple.developer.ubiquity-kvstore-identifier`) —
  backs `CloudKeyValueSync`, see below. No CloudKit container is used; this is
  the lightweight `NSUbiquitousKeyValueStore` API, capped at 1MB / 1024 keys,
  which is generous for the small state this app syncs.

To add a new entitlement: edit the `.entitlements` file directly (it's a plain
plist) — the file is auto-discovered by Xcode's synchronized root group, no
project.pbxproj changes needed beyond the one-time `CODE_SIGN_ENTITLEMENTS` wiring
already in place.

## iCloud sync

Three stores mirror their state to iCloud so it follows the user across devices:

| Store | Data | Conflict strategy |
|---|---|---|
| `DanceStore` | favorite dance IDs | last-writer-wins by timestamp |
| `CurriculumStore` | completed module IDs | last-writer-wins by timestamp |
| `PracticeStore` | practice log entries | union merge (append-only log) |

The engine (`WesternDanceStudio/Utilities/CloudKeyValueSync.swift`) is a thin
wrapper around `NSUbiquitousKeyValueStore`. Each store decides its own merge
policy — favorites/completed-modules are current *toggle state*, where a stale
device's data must never resurrect something a newer device removed, so
last-writer-wins is correct. The practice log is an *append-only ledger*,
where losing a locally-logged session because a sync raced would be wrong, so
it unions instead.

The comparison/merge logic (`DanceStore.shouldAdoptRemote`, `PracticeStore.union`)
is extracted as pure static functions specifically so it's unit-testable without
touching the live `NSUbiquitousKeyValueStore` singleton — see
`WesternDanceStudioTests/CloudKeyValueSyncTests.swift`.

**Simulator note:** `NSUbiquitousKeyValueStore` requires a signed-in iCloud
account and doesn't reliably sync between two simulators. Test sync behavior
on physical devices signed into the same Apple ID, or by exercising
`CloudKeyValueSync`'s pure logic via the test target.

## Logging

All `print()` calls have been replaced with `os.Logger` via the `AppLog` catalog
(`WesternDanceStudio/Utilities/AppLog.swift`) — one `Logger` per subsystem area
(`iap`, `ads`, `consent`, `metronome`, `data`, `media`, `cloudSync`), all sharing
the app's bundle ID so they group together in Console.app / `log stream --predicate`.

Standard practice this follows, and why it replaces `print()` + `#if DEBUG`:

- **Levels** (`debug`/`info`/`error`/`fault`) instead of every message being
  equally loud — filter by severity in Console.app without recompiling.
- **Zero-cost when not observed** — no need to wrap calls in `#if DEBUG`;
  the logging system itself gates cost, and `fault`/`error` still surface in
  Release builds via sysdiagnose if ever needed.
- **Privacy-aware interpolation** — string interpolation values default to
  `private` (redacted in Console.app unless the device is running with a
  debug profile); pass `privacy: .public` explicitly per-argument for values
  safe to see in the field (counts, booleans, non-PII identifiers).

When adding a new subsystem area, add a `Logger` to `AppLog` rather than
constructing one ad hoc — keeps categories consistent and discoverable.

## Testing

`WesternDanceStudioTests/` is a unit-test target hosted inside the app process
(`TEST_HOST` = the app binary), so `UserDefaults.standard` in tests is the same
container the app itself uses. Tests that mutate shared singleton state
(`DanceStore`, `CurriculumStore`, `PracticeStore`, `ReviewManager`) follow a
capture-mutate-restore convention: read the prior value, exercise the
mutation, assert, then restore the original value (either explicitly or by
toggling back). See `DanceStoreTests.swift` for the pattern.

Where a store's core decision logic can be tested without touching shared
state or an unmockable system API (`NSUbiquitousKeyValueStore` isn't
meaningfully fakeable), it's extracted as a pure `static` function — e.g.
`DanceStore.shouldAdoptRemote`, `PracticeStore.union` — and tested directly.
This is the same reasoning `ReviewManager`'s threshold carry-forward logic
follows implicitly: the more decision logic lives in small pure functions, the
less a future bug has to be reproduced live to be isolated.

Run tests:

```bash
xcodebuild test -scheme "Western Dance Studio" -destination "platform=iOS Simulator,name=iPhone 17"
```
