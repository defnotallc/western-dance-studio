import Foundation

struct PracticeEntry: Codable, Hashable {
    let danceID: String
    let date: Date
}

/// Tracks logged practice sessions. Mirrors to iCloud via `CloudKeyValueSync`
/// using union-merge (not last-writer-wins) because this is an append-only
/// log: a session logged on one device between syncs must never be dropped
/// just because another device pushed first.
@Observable
@MainActor
final class PracticeStore {
    static let shared = PracticeStore()

    private(set) var entries: [PracticeEntry] = []

    private enum Keys {
        static let log = "PracticeStore.log"
        static let cloudKey = "sync.PracticeStore.log"
    }

    let defaults: UserDefaults
    private let log = AppLog.data
    private var isApplyingRemote = false

    private init() {
        self.defaults = .standard
        load()
        CloudKeyValueSync.shared.register(key: Keys.cloudKey) { [weak self] data in
            self?.applyRemote(data)
        }
    }

    #if DEBUG
    /// Testing entry point — uses an isolated UserDefaults suite so tests
    /// don't bleed state into the production store or between test runs.
    init(defaults: UserDefaults) {
        self.defaults = defaults
        load()
        // Skip CloudKeyValueSync registration in test instances.
    }
    #endif

    // MARK: - Mutations

    func logPractice(danceID: String) {
        entries.append(PracticeEntry(danceID: danceID, date: Date()))
        ReviewManager.shared.recordEngagement()
        save()
    }

    // MARK: - Per-dance queries

    func practiceCount(for danceID: String) -> Int {
        entries.filter { $0.danceID == danceID }.count
    }

    func lastPracticed(_ danceID: String) -> Date? {
        entries.filter { $0.danceID == danceID }.map(\.date).max()
    }

    func practicedToday(_ danceID: String) -> Bool {
        guard let last = lastPracticed(danceID) else { return false }
        return Calendar.current.isDateInToday(last)
    }

    // MARK: - Streak & aggregate stats

    /// Consecutive days (including today) with at least one logged practice.
    var currentStreak: Int {
        let calendar = Calendar.current
        let practiceDays = Set(entries.map { calendar.startOfDay(for: $0.date) })
        var streak = 0
        var day = calendar.startOfDay(for: Date())
        while practiceDays.contains(day) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    var totalSessions: Int { entries.count }

    var uniqueDancesPracticed: Int { Set(entries.map(\.danceID)).count }

    /// Days within the last `days` that had at least one practice (start-of-day dates).
    func activeDays(inLast days: Int) -> Set<Date> {
        let calendar = Calendar.current
        guard let cutoff = calendar.date(byAdding: .day, value: -days, to: Date()) else { return [] }
        let recent = entries.filter { $0.date >= cutoff }
        return Set(recent.map { calendar.startOfDay(for: $0.date) })
    }

    // MARK: - Persistence

    private func save() {
        guard let payload = try? JSONEncoder().encode(entries) else {
            log.error("Failed to encode practice log")
            return
        }
        defaults.set(payload, forKey: Keys.log)
        guard !isApplyingRemote else { return }
        CloudKeyValueSync.shared.push(key: Keys.cloudKey, payload: payload)
    }

    private func load() {
        guard
            let data = defaults.data(forKey: Keys.log),
            let decoded = try? JSONDecoder().decode([PracticeEntry].self, from: data)
        else { return }
        entries = decoded
    }

    private func applyRemote(_ data: Data) {
        guard let remoteEntries = try? JSONDecoder().decode([PracticeEntry].self, from: data) else {
            log.error("Failed to decode remote practice log")
            return
        }
        let merged = Self.union(local: entries, remote: remoteEntries)
        guard merged.count != entries.count else {
            log.debug("Remote practice log had nothing new to merge")
            return
        }
        log.info("Merged \(merged.count - self.entries.count, privacy: .public) new practice entries from iCloud")
        isApplyingRemote = true
        entries = merged
        save()
        isApplyingRemote = false
    }

    /// Pure union merge extracted for unit testing without iCloud. Dedupes by
    /// (danceID, date) — the pair StoreKit-style identity for an entry — and
    /// returns entries sorted oldest-first, matching append order.
    static func union(local: [PracticeEntry], remote: [PracticeEntry]) -> [PracticeEntry] {
        var seen = Set<PracticeEntry>()
        var result: [PracticeEntry] = []
        for entry in (local + remote).sorted(by: { $0.date < $1.date }) {
            guard !seen.contains(entry) else { continue }
            seen.insert(entry)
            result.append(entry)
        }
        return result
    }
}
