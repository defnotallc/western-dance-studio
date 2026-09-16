import Foundation
import FoundationModels
import Observation

/// On-device language-model helpers for coaching and search.
///
/// Everything here is strictly additive. `FoundationModels` requires an Apple
/// Intelligence capable device, so every entry point is gated on
/// `isSupported` and every caller keeps a non-AI path that works on an
/// iPhone 11. Nothing in this type runs on launch or in the background — the
/// model is only ever invoked from an explicit user action.
@MainActor
@Observable
final class DanceIntelligence {
    static let shared = DanceIntelligence()

    private let log = AppLog.data

    /// A session is created lazily per request rather than held open, so no
    /// model resources are retained while the user is elsewhere in the app.
    private init() {}

    // MARK: - Availability

    /// True when the on-device model can actually serve a request right now.
    /// Re-read at each call site — availability changes as the system downloads
    /// assets or the user toggles Apple Intelligence.
    var isSupported: Bool {
        SystemLanguageModel.default.isAvailable
    }

    /// Human-readable reason the feature is hidden, for diagnostics only.
    var unavailabilityReason: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(let reason):
            return String(describing: reason)
        }
    }

    // MARK: - Coaching

    /// Rewrites a known mistake into direct, second-person coaching.
    ///
    /// The prompt is grounded entirely in the app's own curated text, so the
    /// model is rephrasing content the app already ships rather than inventing
    /// dance instruction.
    func coachingTip(for error: CommonError) async throws -> String {
        let session = LanguageModelSession(
            instructions: """
            You are a patient country-western dance instructor talking to a beginner \
            on the edge of the dance floor. Rewrite the supplied mistake as direct, \
            encouraging coaching in at most three sentences. Speak in second person. \
            Only use the information given — never invent steps, counts, or terminology.
            """
        )
        let response = try await session.respond(
            to: """
            Mistake: \(error.title)
            What it looks like: \(error.symptom)
            Why it happens: \(error.cause)
            The fix: \(error.fix)
            """
        )
        return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Natural-language search

    /// Structured result so the model returns IDs we can resolve, rather than
    /// prose we would have to parse.
    @Generable
    struct DanceMatches {
        @Guide(description: "Matching dance IDs, best match first. Empty if nothing fits.")
        var danceIDs: [String]
    }

    /// Maps a free-text query ("something slow for a first date") onto dance IDs.
    ///
    /// Returns IDs only; the caller resolves them against its own catalogue and
    /// silently drops anything unrecognised, so a hallucinated ID cannot put a
    /// non-existent dance on screen.
    func matchingDanceIDs(for query: String, in dances: [Dance]) async throws -> [String] {
        let catalogue = dances.map { dance in
            "\(dance.id) | \(dance.name) | \(dance.category.rawValue) | \(dance.bpm) BPM | difficulty \(dance.difficulty)/5 | \(dance.summary)"
        }.joined(separator: "\n")

        let session = LanguageModelSession(
            instructions: """
            You match a dancer's free-text request to dances from a fixed catalogue. \
            Return only IDs that appear verbatim in the catalogue, best match first, \
            at most five. If nothing genuinely fits, return an empty list rather than \
            guessing.
            """
        )
        let response = try await session.respond(
            to: """
            Catalogue (id | name | category | tempo | difficulty | summary):
            \(catalogue)

            Request: \(query)
            """,
            generating: DanceMatches.self
        )

        // Drop anything not in the catalogue — the model is advisory, the
        // catalogue is authoritative.
        let valid = Set(dances.map(\.id))
        let matches = response.content.danceIDs.filter(valid.contains)
        log.debug("Semantic search matched \(matches.count, privacy: .public) dances")
        return matches
    }
}
