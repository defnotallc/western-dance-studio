import Foundation

struct PracticeEntry: Codable {
    let danceID: String
    let date: Date
}

@Observable
@MainActor
final class PracticeStore {
    static let shared = PracticeStore()

    private(set) var entries: [PracticeEntry] = []

    private enum Keys {
        static let log = "PracticeStore.log"
    }

    private init() { load() }

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
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: Keys.log)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: Keys.log),
            let decoded = try? JSONDecoder().decode([PracticeEntry].self, from: data)
        else { return }
        entries = decoded
    }
}
