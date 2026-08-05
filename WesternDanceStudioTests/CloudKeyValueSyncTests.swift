import XCTest
@testable import Western_Dance_Studio

/// Tests the pure conflict-resolution logic each store uses for iCloud sync,
/// without touching `NSUbiquitousKeyValueStore` itself (which isn't
/// meaningfully mockable — it's a live singleton backed by daemon state).
/// `shouldAdoptRemote` and `union` are extracted as static, side-effect-free
/// functions specifically so this reasoning is testable in isolation.
final class CloudKeyValueSyncTests: XCTestCase {

    // MARK: - Last-writer-wins (DanceStore / CurriculumStore)

    @MainActor
    func testNewerRemoteIsAdopted() {
        let local = Date()
        let remote = local.addingTimeInterval(60)
        XCTAssertTrue(DanceStore.shouldAdoptRemote(remoteTimestamp: remote, localTimestamp: local))
    }

    @MainActor
    func testOlderRemoteIsRejected() {
        let local = Date()
        let remote = local.addingTimeInterval(-60)
        XCTAssertFalse(DanceStore.shouldAdoptRemote(remoteTimestamp: remote, localTimestamp: local))
    }

    @MainActor
    func testEqualTimestampFavorsLocal() {
        let now = Date()
        // Equal timestamps must not adopt remote — local already reflects
        // this state, and adopting would be a needless no-op write at best.
        XCTAssertFalse(DanceStore.shouldAdoptRemote(remoteTimestamp: now, localTimestamp: now))
    }

    // MARK: - Union merge (PracticeStore)

    func testUnionMergeDedupesIdenticalEntries() {
        let date = Date()
        let entry = PracticeEntry(danceID: "two-step", date: date)
        let merged = PracticeStore.union(local: [entry], remote: [entry])
        XCTAssertEqual(merged.count, 1, "identical (danceID, date) pairs must dedupe to one entry")
    }

    func testUnionMergeKeepsDisjointEntriesFromBothSides() {
        let now = Date()
        let localOnly = PracticeEntry(danceID: "waltz", date: now)
        let remoteOnly = PracticeEntry(danceID: "two-step", date: now.addingTimeInterval(120))
        let merged = PracticeStore.union(local: [localOnly], remote: [remoteOnly])
        XCTAssertEqual(merged.count, 2, "entries unique to either side must both survive the merge")
        XCTAssertTrue(merged.contains(localOnly))
        XCTAssertTrue(merged.contains(remoteOnly))
    }

    func testUnionMergeNeverDropsLocalEntries() {
        // The whole point of union-merge over last-writer-wins for an
        // append-only log: a session logged locally between syncs must
        // survive even if the remote payload doesn't know about it yet.
        let now = Date()
        let local = [
            PracticeEntry(danceID: "two-step", date: now),
            PracticeEntry(danceID: "waltz", date: now.addingTimeInterval(30)),
        ]
        let remote = [PracticeEntry(danceID: "line-dance", date: now.addingTimeInterval(-30))]
        let merged = PracticeStore.union(local: local, remote: remote)
        for entry in local {
            XCTAssertTrue(merged.contains(entry), "local entry \(entry) must survive union merge")
        }
        XCTAssertEqual(merged.count, 3)
    }

    func testUnionMergeIsSortedOldestFirst() {
        let now = Date()
        let earlier = PracticeEntry(danceID: "waltz", date: now)
        let later = PracticeEntry(danceID: "two-step", date: now.addingTimeInterval(3600))
        let merged = PracticeStore.union(local: [later], remote: [earlier])
        XCTAssertEqual(merged.map(\.danceID), ["waltz", "two-step"], "merged log must be oldest-first")
    }

    func testUnionMergeOfEmptyRemoteReturnsLocalUnchanged() {
        let entries = [PracticeEntry(danceID: "two-step", date: Date())]
        let merged = PracticeStore.union(local: entries, remote: [])
        XCTAssertEqual(merged, entries)
    }
}
