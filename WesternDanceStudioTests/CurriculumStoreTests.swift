import XCTest
@testable import Western_Dance_Studio

@MainActor
final class CurriculumStoreTests: XCTestCase {
    private var store: CurriculumStore { CurriculumStore.shared }
    private var firstModule: CurriculumModule { CurriculumModule.all[0] }

    func testToggleCompleteFlipsState() {
        let module = firstModule
        let before = store.isComplete(module)
        store.toggleComplete(module)
        XCTAssertNotEqual(store.isComplete(module), before)
        store.toggleComplete(module) // restore
    }

    func testDoubleToggleRestoresState() {
        let module = firstModule
        let before = store.isComplete(module)
        store.toggleComplete(module)
        store.toggleComplete(module)
        XCTAssertEqual(store.isComplete(module), before)
    }

    func testMarkCompleteIsIdempotent() {
        let module = firstModule
        let wasComplete = store.isComplete(module)
        store.markComplete(module)
        store.markComplete(module)
        XCTAssertTrue(store.isComplete(module))
        if !wasComplete { store.toggleComplete(module) } // restore
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
}
