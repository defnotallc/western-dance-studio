import Foundation

@Observable
@MainActor
final class CurriculumStore {
    static let shared = CurriculumStore()

    private(set) var completedModuleIDs: Set<String>

    private enum Keys {
        static let completed = "CurriculumStore.completedModuleIDs"
    }

    private init() {
        let saved = UserDefaults.standard.stringArray(forKey: Keys.completed) ?? []
        completedModuleIDs = Set(saved)
    }

    // MARK: - Mutations

    func toggleComplete(_ module: CurriculumModule) {
        if completedModuleIDs.contains(module.id) {
            completedModuleIDs.remove(module.id)
        } else {
            completedModuleIDs.insert(module.id)
            ReviewManager.shared.recordEngagement()
        }
        persist()
    }

    func markComplete(_ module: CurriculumModule) {
        completedModuleIDs.insert(module.id)
        persist()
    }

    // MARK: - Queries

    func isComplete(_ module: CurriculumModule) -> Bool {
        completedModuleIDs.contains(module.id)
    }

    var completedCount: Int { completedModuleIDs.count }

    var totalCount: Int { CurriculumModule.all.count }

    var completionFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var nextIncompleteModule: CurriculumModule? {
        CurriculumModule.all.first { !completedModuleIDs.contains($0.id) }
    }

    // MARK: - Persistence

    private func persist() {
        UserDefaults.standard.set(Array(completedModuleIDs), forKey: Keys.completed)
    }
}
