import Foundation
import os

/// Envelope wrapping a synced value with the timestamp it was last written,
/// so last-writer-wins conflict resolution can compare freshness across devices.
struct SyncEnvelope<Value: Codable>: Codable {
    var timestamp: Date
    var value: Value

    /// True if `self` was written after `other` and should win a conflict.
    func isNewer(than other: SyncEnvelope<Value>) -> Bool {
        timestamp > other.timestamp
    }
}

/// Mirrors small pieces of app state (favorites, completed lessons, practice
/// log) to iCloud via `NSUbiquitousKeyValueStore`, so a signed-in user's
/// progress follows them across devices.
///
/// Requires the "iCloud > Key-value storage" capability and the
/// `com.apple.developer.ubiquity-kvstore-identifier` entitlement — see
/// `WesternDanceStudio.entitlements`. `NSUbiquitousKeyValueStore` caps out at
/// 1MB total / 1024 keys, which is generous for the small state this app
/// tracks (a few hundred string IDs and a practice log).
///
/// Conflict strategy: each store decides for itself. `register` hands the
/// store's `onRemoteUpdate` closure the raw remote payload whenever iCloud
/// reports a change; the store decodes it and merges however is correct for
/// its data shape (see `DanceStore`/`CurriculumStore` for last-writer-wins,
/// `PracticeStore` for union-merge of an append-only log).
@MainActor
final class CloudKeyValueSync {
    static let shared = CloudKeyValueSync()

    private let store = NSUbiquitousKeyValueStore.default
    private var handlers: [String: (Data) -> Void] = [:]

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleExternalChange(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store
        )
        let ok = store.synchronize()
        AppLog.cloudSync.info("Initial synchronize() → \(ok, privacy: .public)")
    }

    /// Registers a merge handler for `key` and immediately delivers any value
    /// already sitting in iCloud (covers the case where a value arrived while
    /// the store that owns it hadn't launched yet, e.g. a fresh install).
    func register(key: String, onRemoteUpdate: @escaping (Data) -> Void) {
        handlers[key] = onRemoteUpdate
        if let existing = store.data(forKey: key) {
            AppLog.cloudSync.debug("Delivering existing iCloud value for \(key, privacy: .public) at registration")
            onRemoteUpdate(existing)
        }
    }

    /// Pushes a local payload to iCloud under `key`.
    func push(key: String, payload: Data) {
        store.set(payload, forKey: key)
        let ok = store.synchronize()
        AppLog.cloudSync.debug("Pushed \(payload.count, privacy: .public)B for \(key, privacy: .public), synchronize()=\(ok, privacy: .public)")
    }

    @objc private func handleExternalChange(_ note: Notification) {
        guard
            let info = note.userInfo,
            let reason = info[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int,
            let keys = info[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String]
        else {
            AppLog.cloudSync.error("External change notification missing expected userInfo")
            return
        }

        AppLog.cloudSync.info("External change (reason=\(reason, privacy: .public)) for keys: \(keys.joined(separator: ", "), privacy: .public)")

        for key in keys {
            guard let handler = handlers[key], let data = store.data(forKey: key) else { continue }
            handler(data)
        }
    }
}
