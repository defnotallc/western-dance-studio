import SwiftUI
import UniformTypeIdentifiers

/// Markdown export of the practice log, using the iOS 27 `WritableDocument`
/// protocol.
///
/// Gated to iOS 27 because `WritableDocument` / `DocumentWriter` are new in
/// that release. The app's deployment target is lower, so `SettingsView` only
/// offers the export when the API is present — nothing else in the app depends
/// on this type.
@available(iOS 27.0, *)
final class PracticeLogDocument: WritableDocument {
    /// Writes the rendered Markdown to the destination the exporter chose.
    /// The payload is a single small string, so there is no incremental
    /// progress worth reporting.
    struct Writer: DocumentWriter {
        typealias Destination = URL

        func write(snapshot: sending String,
                   to destination: sending URL,
                   previous: sending String?,
                   progress: consuming Subprogress) async throws {
            try snapshot.write(to: destination, atomically: true, encoding: .utf8)
        }
    }

    static var writableContentTypes: [UTType] { [.markdown] }

    private let markdown: String

    init(markdown: String) {
        self.markdown = markdown
    }

    func writer(configuration: sending WriteConfiguration) -> sending Writer {
        Writer()
    }

    @MainActor
    func snapshot(contentType: UTType) async throws -> sending String {
        markdown
    }
}

/// Attaches the exporter only where the API exists, keeping the `#available`
/// check out of `SettingsView`'s body.
struct PracticeLogExporter: ViewModifier {
    @Binding var isPresented: Bool
    let markdown: String

    func body(content: Content) -> some View {
        if #available(iOS 27.0, *) {
            content.fileExporter(
                isPresented: $isPresented,
                document: PracticeLogDocument(markdown: markdown),
                contentType: .markdown,
                defaultFilename: "Practice Log"
            ) { result in
                if case .failure(let error) = result {
                    AppLog.data.error("Practice log export failed: \(error.localizedDescription, privacy: .public)")
                }
            }
        } else {
            content
        }
    }
}
