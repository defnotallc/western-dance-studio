import Foundation

/// Parsing for the `westerndance://` URL scheme.
///
/// Kept separate from the view that handles the link so the parsing rules are
/// unit-testable and the failure cases are explicit: anything unrecognised
/// resolves to `nil` and is ignored rather than partially routed.
enum DeepLink: Equatable {
    /// `westerndance://practice?dance=<id>` — open the metronome preloaded
    /// with that dance's tempo and rhythm.
    case practice(danceID: String)

    static let scheme = "westerndance"

    init?(url: URL) {
        guard url.scheme?.lowercased() == Self.scheme,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return nil }

        switch components.host?.lowercased() {
        case "practice":
            guard let id = components.queryItems?
                .first(where: { $0.name == "dance" })?
                .value,
                !id.isEmpty
            else { return nil }
            self = .practice(danceID: id)
        default:
            return nil
        }
    }
}
