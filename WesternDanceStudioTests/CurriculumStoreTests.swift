import XCTest
@testable import Western_Dance_Studio

@MainActor
final class CurriculumStoreTests: XCTestCase {
    private var store: CurriculumStore!
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() async throws {
        try await super.setUp()
        suiteName = "CurriculumStoreTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        store = CurriculumStore(defaults: defaults)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suiteName)
        store = nil
        defaults = nil
        suiteName = nil
        try await super.tearDown()
    }

    private var firstModule: CurriculumModule { CurriculumModule.all[0] }

    func testToggleCompleteFlipsState() {
        let module = firstModule
        XCTAssertFalse(store.isComplete(module))
        store.toggleComplete(module)
        XCTAssertTrue(store.isComplete(module))
    }

    func testDoubleToggleRestoresState() {
        let module = firstModule
        store.toggleComplete(module)
        store.toggleComplete(module)
        XCTAssertFalse(store.isComplete(module))
    }

    func testMarkCompleteIsIdempotent() {
        let module = firstModule
        store.markComplete(module)
        store.markComplete(module)
        XCTAssertTrue(store.isComplete(module))
    }

    func testCompletionFractionMatchesCompletedCount() {
        XCTAssertEqual(
            store.completionFraction,
            Double(store.completedCount) / Double(store.totalCount),
            accuracy: 0.0001
        )
    }

    func testTotalCountMatchesAllModules() {
        XCTAssertEqual(store.totalCount, CurriculumModule.all.count)
    }

    func testNextIncompleteModuleIsNilOnlyWhenAllComplete() {
        if store.completedCount == store.totalCount {
            XCTAssertNil(store.nextIncompleteModule)
        } else {
            XCTAssertNotNil(store.nextIncompleteModule)
            XCTAssertFalse(store.isComplete(store.nextIncompleteModule!))
        }
    }

    func testCompletionPersistedToDefaults() {
        let module = firstModule
        store.markComplete(module)
        let store2 = CurriculumStore(defaults: defaults)
        XCTAssertTrue(store2.isComplete(module), "completion must survive a store re-init from the same defaults")
    }
}
