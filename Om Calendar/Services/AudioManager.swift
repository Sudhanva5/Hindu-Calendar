import Foundation
import AVFoundation

class AudioManager: NSObject {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    func playOmChant() {
        guard !isPlaying else { return }
        
        // First try to load from main bundle
        if let url = Bundle.main.url(forResource: "om-chant", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.volume = 0.5 // Start at 50% volume
                audioPlayer?.prepareToPlay() // Pre-load the audio
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("Failed to play Om chant: \(error.localizedDescription)")
                handleAudioError()
            }
        } else {
            print("Om chant audio file not found in bundle")
            handleAudioError()
        }
    }
    
    func stopOmChant() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func setVolume(_ volume: Float) {
        // Ensure volume is between 0 and 1
        let clampedVolume = max(0, min(volume, 1))
        audioPlayer?.volume = clampedVolume
    }
    
    func fadeOut(duration: TimeInterval = 2.0) {
        guard let player = audioPlayer, isPlaying else { return }
        
        let startVolume = player.volume
        let volumeStep = startVolume / Float(duration * 10) // Update 10 times per second
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if player.volume > volumeStep {
                player.volume -= volumeStep
            } else {
                self.stopOmChant()
                timer.invalidate()
            }
        }
    }
    
    private func handleAudioError() {
        // Reset state
        isPlaying = false
        audioPlayer = nil
        
        // Notify user or handle error (you can add your own error handling here)
        NotificationCenter.default.post(
            name: NSNotification.Name("AudioManagerError"),
            object: nil,
            userInfo: ["message": "Failed to play meditation audio"]
        )
    }
    
    // Handle interruptions (phone calls, etc.)
    @objc func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Audio session was interrupted, pause the audio
            audioPlayer?.pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption ended, resume playing
                audioPlayer?.play()
            }
        @unknown default:
            break
        }
    }
} 