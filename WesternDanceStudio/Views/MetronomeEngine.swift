import SwiftUI
import AVFoundation
import Observation

/// Manages metronome audio and timing.
@Observable
@MainActor
final class MetronomeEngine {
    var isPlaying: Bool = false
    var beatPulse: Bool = false
    var accentPulse: Bool = false

    /// 1-based position within the current rhythm pattern cycle; 0 when stopped.
    private(set) var currentBeat: Int = 0

    var bpm: Double = 140 {
        didSet {
            guard oldValue != bpm else { return }
            if isPlaying { restart() }
        }
    }

    var rhythmPattern: RhythmPattern = .steady {
        didSet {
            currentBeat = 0
            if isPlaying { restart() }
        }
    }

    var countInEnabled: Bool = false

    private var audioPlayer: AVAudioPlayer?
    private let timerHolder = TimerHolder()
    private var audioSessionConfigured = false
    private var countInRemaining: Int = 0

    func start() {
        guard !isPlaying else { return }
        isPlaying = true
        currentBeat = 0
        countInRemaining = countInEnabled ? 4 : 0
        configureAudioSessionIfNeeded()
        preparePlayer()
        scheduleTimer()
    }

    func stop() {
        guard isPlaying else { return }
        isPlaying = false
        currentBeat = 0
        timerHolder.cancel()
        audioPlayer?.stop()
        deactivateAudioSession()
    }

    func toggle() {
        if isPlaying { stop() } else { start() }
    }

    private func restart() {
        guard isPlaying else { return }
        currentBeat = 0
        countInRemaining = countInEnabled ? 4 : 0
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
            MainActor.assumeIsolated { self?.fireBeat() }
        }
        newTimer.resume()
        timerHolder.set(newTimer)
    }

    private func fireBeat() {
        guard isPlaying else { return }

        // Count-in: 4 steady preparatory clicks before the pattern starts.
        if countInRemaining > 0 {
            countInRemaining -= 1
            playClick(accent: countInRemaining == 3)
            return
        }

        // Advance position within the rhythm pattern cycle.
        currentBeat = (currentBeat % rhythmPattern.length) + 1

        guard rhythmPattern.soundsOnBeat(currentBeat) else { return }
        playClick(accent: rhythmPattern.isAccent(currentBeat))
    }

    private func playClick(accent: Bool) {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
        beatPulse = true
        accentPulse = accent
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(80))
            beatPulse = false
            accentPulse = false
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
