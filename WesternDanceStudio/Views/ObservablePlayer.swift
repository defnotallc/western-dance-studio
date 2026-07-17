import SwiftUI
import AVKit

/// Wraps an AVPlayer with @Observable so SwiftUI views can react to changes.
///
/// Looping support was intentionally removed until it's actually used by a view.
/// Adding observers requires careful Swift 6 concurrency handling; we'll add it
/// back when there's a real consumer.
@Observable
@MainActor
final class ObservablePlayer {
    var player: AVPlayer?

    func setup(with url: URL?) {
        guard let url else { return }

        // If same URL as current, just reset position.
        if let currentURL = (player?.currentItem?.asset as? AVURLAsset)?.url, currentURL == url {
            player?.seek(to: .zero)
            return
        }
        player = AVPlayer(url: url)
    }

    /// Explicit teardown; call from `.onDisappear` when appropriate.
    func teardown() {
        player?.pause()
        player = nil
    }
}
