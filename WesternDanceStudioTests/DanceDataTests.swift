import XCTest
@testable import Western_Dance_Studio

final class DanceDataTests: XCTestCase {
    private let dances = Dance.sampleDances

    func testSampleDancesIsNonEmpty() {
        XCTAssertFalse(dances.isEmpty, "Dance.sampleDances must not be empty")
    }

    func testAllDanceIDsAreUnique() {
        let ids = dances.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "All dance IDs must be unique")
    }

    func testAllDancesHaveNonEmptyName() {
        for dance in dances {
            XCTAssertFalse(dance.name.isEmpty, "\(dance.id): name must not be empty")
        }
    }

    func testAllDancesHaveNonEmptySummary() {
        for dance in dances {
            XCTAssertFalse(dance.summary.isEmpty, "\(dance.name): summary must not be empty")
        }
    }

    func testDifficultyIsInValidRange() {
        for dance in dances {
            XCTAssert(dance.difficulty >= 1 && dance.difficulty <= 10,
                      "\(dance.name): difficulty \(dance.difficulty) must be in 1–10")
        }
    }

    func testAllDancesHaveLeadSteps() {
        for dance in dances {
            XCTAssertFalse(dance.leadSteps.isEmpty,
                           "\(dance.name): leadSteps must not be empty")
        }
    }

    func testPartnerDancesHaveFollowSteps() {
        for dance in dances where dance.hasPartnerPerspectives {
            XCTAssertFalse(dance.followSteps.isEmpty,
                           "\(dance.name): partner dance with perspectives must have follow steps")
        }
    }

    func testLineDancesAreNotPartnerDances() {
        for dance in dances where dance.category == .lineDance {
            XCTAssertFalse(dance.isPartnerDance,
                           "\(dance.name): line dance must not be a partner dance")
        }
    }

    func testKnownDancesPresent() {
        let names = Set(dances.map(\.name))
        XCTAssertTrue(names.contains("Texas Two-Step"), "Texas Two-Step must be present")
        XCTAssertTrue(names.contains("Waltz"),          "Waltz must be present")
    }

    func testAllCategoriesRepresented() {
        let usedCategories = Set(dances.map(\.category))
        for cat in Dance.DanceCategory.allCases {
            XCTAssertTrue(usedCategories.contains(cat),
                          "Category '\(cat.rawValue)' must have at least one dance")
        }
    }

    func testSearchByNameFindsKnownDance() {
        let results = dances.filter {
            $0.name.localizedCaseInsensitiveContains("two step")
        }
        XCTAssertFalse(results.isEmpty, "Should find dances matching 'two step'")
    }

    func testNonsenseSearchReturnsEmpty() {
        let results = dances.filter {
            $0.name.localizedCaseInsensitiveContains("XYZNOTADANCE99")
                || $0.summary.localizedCaseInsensitiveContains("XYZNOTADANCE99")
        }
        XCTAssertTrue(results.isEmpty, "Nonsense query must return empty")
    }

    func testGroupByCategoryIsComplete() {
        let grouped = Dictionary(grouping: dances, by: \.category)
        for (cat, group) in grouped {
            XCTAssertFalse(group.isEmpty,
                           "Category '\(cat.rawValue)' group must not be empty")
        }
    }

    // MARK: - Referential Integrity

    func testModuleDanceIDsResolve() {
        let danceIDs = Set(dances.map(\.id))
        for module in CurriculumModule.all {
            for id in module.danceIDs {
                XCTAssertTrue(danceIDs.contains(id),
                              "Module '\(module.id)' references unknown danceID '\(id)'")
            }
        }
    }

    func testModuleGlossaryTermsResolve() {
        let termNames = Set(DanceTerm.allTerms.map(\.term))
        for module in CurriculumModule.all {
            for name in module.glossaryTerms {
                XCTAssertTrue(termNames.contains(name),
                              "Module '\(module.id)' references unknown glossary term '\(name)'")
            }
        }
    }

    func testCommonErrorDanceIDsResolve() {
        let danceIDs = Set(dances.map(\.id))
        for error in CommonError.all {
            for id in error.danceIDs {
                XCTAssertTrue(danceIDs.contains(id),
                              "CommonError '\(error.id)' references unknown danceID '\(id)'")
            }
        }
    }

    func testCommonErrorModuleIDsResolve() {
        let moduleIDs = Set(CurriculumModule.all.map(\.id))
        for error in CommonError.all {
            for id in error.moduleIDs {
                XCTAssertTrue(moduleIDs.contains(id),
                              "CommonError '\(error.id)' references unknown moduleID '\(id)'")
            }
        }
    }

    func testStepSheetDanceIDsResolve() {
        let danceIDs = Set(dances.map(\.id))
        for dance in dances {
            if let sheet = dance.stepSheet {
                XCTAssertTrue(danceIDs.contains(dance.id),
                              "LineDanceStepSheet attached to unknown danceID '\(dance.id)' (sheet id: \(sheet.id))")
            }
        }
    }
}
