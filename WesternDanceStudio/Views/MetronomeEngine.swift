import SwiftUI
import AVFoundation
import Observation

/// Manages metronome audio and timing.
@Observable
@MainActor
final class MetronomeEngine {
    var isPlaying: Bool = false
    var beatPulse: Bool = false

    var bpm: Double = 140 {
        didSet {
            guard oldValue != bpm else { return }
            if isPlaying { restart() }
        }
    }

    private var audioPlayer: AVAudioPlayer?
    /// Reference-type holder so `deinit` (nonisolated) can cancel the timer without
    /// touching main-actor state. `DispatchSourceTimer.cancel()` is thread-safe.
    private let timerHolder = TimerHolder()
    private var audioSessionConfigured = false

    func start() {
        guard !isPlaying else { return }
        isPlaying = true
        configureAudioSessionIfNeeded()
        preparePlayer()
        scheduleTimer()
    }

    func stop() {
        guard isPlaying else { return }
        isPlaying = false
        timerHolder.cancel()
        audioPlayer?.stop()
        deactivateAudioSession()
    }

    func toggle() {
        if isPlaying { stop() } else { start() }
    }

    private func restart() {
        guard isPlaying else { return }
        timerHolder.cancel()
        scheduleTimer()
    }

    private func configureAudioSessionIfNeeded() {
        guard !audioSessionConfigured else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            audioSessionConfigured = true
        } catch {
            #if DEBUG
            print("⚠️ AVAudioSession configuration failed: \(error)")
            #endif
        }
    }

    /// Release audio priority so other apps can claim it. Called when the metronome
    /// stops. Uses `.notifyOthersOnDeactivation` so paused music apps can resume.
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
            audioSessionConfigured = false
        } catch {
            #if DEBUG
            print("⚠️ AVAudioSession deactivation failed: \(error)")
            #endif
        }
    }

    private func preparePlayer() {
        guard audioPlayer == nil else { return }
        guard let url = Bundle.main.url(forResource: "metronomeTick", withExtension: "wav") else {
            #if DEBUG
            print("⚠️ metronomeTick.wav not found — metronome will be visual only")
            #endif
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 1.0
        } catch {
            #if DEBUG
            print("Audio player error: \(error)")
            #endif
        }
    }

    private func scheduleTimer() {
        let clampedBPM = max(40.0, min(bpm, 300.0))
        let intervalMs = max(Int(60_000.0 / clampedBPM), 50)

        let newTimer = DispatchSource.makeTimerSource(queue: .main)
        newTimer.schedule(deadline: .now(), repeating: .milliseconds(intervalMs))
        newTimer.setEventHandler { [weak self] in
            Task { @MainActor in
                self?.fireBeat()
            }
        }
        newTimer.resume()
        timerHolder.set(newTimer)
    }

    private func fireBeat() {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
        beatPulse = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(80))
            beatPulse = false
        }
    }
}

/// Thread-safe holder for a DispatchSourceTimer so deinit can cancel it without
/// needing main-actor isolation.
private final class TimerHolder: @unchecked Sendable {
    private let lock = NSLock()
    private var timer: DispatchSourceTimer?

    func set(_ newTimer: DispatchSourceTimer) {
        lock.lock()
        defer { lock.unlock() }
        timer?.cancel()
        timer = newTimer
    }

    func cancel() {
        lock.lock()
        defer { lock.unlock() }
        timer?.cancel()
        timer = nil
    }
}
