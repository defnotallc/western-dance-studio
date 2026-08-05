import SwiftUI
import AVKit
import YouTubePlayerKit

struct MediaPlayerView: View {
    let mediaType: MediaType
    @State private var youtubePlayer = YouTubePlayer()

    enum MediaType: Hashable {
        case image(url: URL?)
        case gif(name: String)
        case localVideo(url: URL?)
        case youtube(videoID: String)
    }

    var body: some View {
        Group {
            switch mediaType {
            case .image(let url):
                imageView(url: url)
            case .gif(let name):
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .localVideo(let url):
                LocalVideoView(url: url)   // ✅ FIX #14: dedicated view holds AVPlayer in @State
            case .youtube(let videoID):
                YouTubePlayerView(youtubePlayer)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .task(id: videoID) {
                        do {
                            try await youtubePlayer.load(source: .video(id: videoID))
                        } catch {
                            AppLog.media.error("Failed to load YouTube video: \(error.localizedDescription, privacy: .public)")
                        }
                    }
            }
        }
        .cornerRadius(12)
        .shadow(radius: 4)
    }

    @ViewBuilder
    private func imageView(url: URL?) -> some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                default:
                    ProgressView()
                }
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Local Video (stable AVPlayer)

private struct LocalVideoView: View {
    let url: URL?
    @State private var player: AVPlayer?

    var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
                    .aspectRatio(16 / 9, contentMode: .fit)
            } else {
                VStack {
                    Image(systemName: "video.slash")
                        .font(.largeTitle)
                    Text("Video coming soon")
                }
                .foregroundStyle(.secondary)
                .frame(height: 200)
            }
        }
        .onAppear {
            if let url, player == nil {
                player = AVPlayer(url: url)
            }
        }
        .onChange(of: url) { _, newURL in
            if let newURL {
                player = AVPlayer(url: newURL)
            } else {
                player = nil
            }
        }
    }
}
