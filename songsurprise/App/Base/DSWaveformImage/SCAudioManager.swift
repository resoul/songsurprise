//
//  SCAudioManager.swift
//  songsurprise
//
//  Created by resoul on 10.09.2024.
//

import Foundation
import AVFoundation

protocol RecordingDelegate: AnyObject {
    func audioManager(_ manager: SCAudioManager, didAllowRecording flag: Bool)
    func audioManager(_ manager: SCAudioManager, didFinishRecordingSuccessfully flag: Bool)
    func audioManager(_ manager: SCAudioManager, didUpdateRecordProgress progress: CGFloat)
}

protocol PlaybackDelegate: AnyObject {
    func audioManager(_ manager: SCAudioManager, didFinishPlayingSuccessfully flag: Bool)
    func audioManager(_ manager: SCAudioManager, didUpdatePlayProgress progress: CGFloat)
}

class SCAudioManager: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    weak var recordingDelegate: RecordingDelegate?
    weak var playbackDelegate: PlaybackDelegate?
    
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var updateProgressIndicatorTimer: Timer?
    private var currentRecordedAudioFilename: String?
    
    var currentRecordingTime: TimeInterval = 0
    
    private let kMinRecordingTime: TimeInterval = 0.3
    private let kMaxRecordingTime: TimeInterval = 90.0
    private let kSCTemporaryRecordedAudioFilename = "audio_temp.m4a"
    private let kSCDownloadedAudioFilename = "loaded_sound.m4a"
    private let kSCRecordingsFolderName = "recordings"
    
    // MARK: - Helper methods
    func recordingsFolderURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return documentsDirectory.appendingPathComponent(kSCRecordingsFolderName)
    }
    
    func recordedAudioFileURL() -> URL? {
        guard let currentFilename = currentRecordedAudioFilename else { return nil }
        return recordingsFolderURL().appendingPathComponent(currentFilename)
    }
    
    func downloadedAudioFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return documentsDirectory.appendingPathComponent(kSCDownloadedAudioFilename)
    }
    
    // MARK: - Audio Recording methods
    func isRecording() -> Bool {
        return recorder?.isRecording ?? false
    }
    
    func startRecording() {
        guard !isRecording() else { return }
        
        if player?.isPlaying == true {
            player?.stop()
            updateProgressIndicatorTimer?.invalidate()
        }
        
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(true)
        
        currentRecordingTime = 0.0
        recorder?.record()
        updateProgressIndicatorTimer?.invalidate()
        updateProgressIndicatorTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(recordingStatusDidUpdate), userInfo: nil, repeats: true)
    }
    
    func lastAveragePower() -> Float {
        return recorder?.averagePower(forChannel: 0) ?? 0
    }
    
    func stopRecording() {
        guard isRecording() else { return }
        recorder?.stop()
        
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(false)
        
        updateProgressIndicatorTimer?.invalidate()
    }
    
    func reset() {
        player?.stop()
        stopRecording()
        recorder?.prepareToRecord()
        currentRecordingTime = 0.0
    }
    
    func setRecordingToBeSentAgain(fromAudioAtURL audioURL: URL) {
        currentRecordingTime = kMinRecordingTime + 1
        copyTemporaryAudioFileToPersistentLocation(audioURL)
        recordingDelegate?.audioManager(self, didFinishRecordingSuccessfully: true)
    }
    
    // MARK: - Recording / Playback Feedback methods
    @objc func recordingStatusDidUpdate() {
        currentRecordingTime = recorder?.currentTime ?? 0
        let progress = CGFloat(max(0, min(1, currentRecordingTime / kMaxRecordingTime)))
        
        recorder?.updateMeters()
        recordingDelegate?.audioManager(self, didUpdateRecordProgress: progress)
        
        if progress >= 1.0 {
            stopRecording()
        }
    }
    
    @objc func playbackStatusDidUpdate() {
        guard let player = player else { return }
        let progress = CGFloat(max(0, min(1, player.currentTime / player.duration)))
        playbackDelegate?.audioManager(self, didUpdatePlayProgress: progress)
    }
    
    func hasCapturedSufficientAudioLength() -> Bool {
        return currentRecordingTime > kMinRecordingTime
    }
    
    // MARK: - Audio Playback methods
    func playAudioFile(fromURL audioURL: URL) {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        
        if recorder?.isRecording == false {
            updateProgressIndicatorTimer?.invalidate()
            updateProgressIndicatorTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(playbackStatusDidUpdate), userInfo: nil, repeats: true)
            
            player = try? AVAudioPlayer(contentsOf: audioURL)
            player?.delegate = self
            player?.play()
        }
    }
    
    func isPlaying() -> Bool {
        return player?.isPlaying ?? false
    }
    
    func startPlayingRecordedAudio() {
        if let url = recordedAudioFileURL() {
            playAudioFile(fromURL: url)
        }
    }
    
    func stopPlayingRecordedAudio() {
        if player?.isPlaying == true {
            player?.stop()
            updateProgressIndicatorTimer?.invalidate()
            playbackDelegate?.audioManager(self, didFinishPlayingSuccessfully: false)
        }
    }
    
    func playDownloadedAudio() {
        playAudioFile(fromURL: downloadedAudioFileURL())
    }
    
    // MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        updateProgressIndicatorTimer?.invalidate()
        
        if hasCapturedSufficientAudioLength() {
            copyTemporaryAudioFileToPersistentLocation(temporaryRecordedAudioFileURL())
        }
        
        recordingDelegate?.audioManager(self, didFinishRecordingSuccessfully: flag)
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateProgressIndicatorTimer?.invalidate()
        playbackDelegate?.audioManager(self, didFinishPlayingSuccessfully: flag)
    }
    
    // MARK: - Private methods
    func temporaryRecordedAudioFileURL() -> URL {
        let homeDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return homeDirectory.appendingPathComponent(kSCTemporaryRecordedAudioFilename)
    }
    
    func prepareAudioRecording() {
        let outputFileURL = temporaryRecordedAudioFileURL()
        
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord)
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1
        ]
        
        recorder = try? AVAudioRecorder(url: outputFileURL, settings: recordSettings)
        recorder?.delegate = self
        recorder?.isMeteringEnabled = true
        
        session.requestRecordPermission { [weak self] granted in
            self?.recordingDelegate?.audioManager(self!, didAllowRecording: granted)
            self?.recorder?.prepareToRecord()
        }
    }
    
    func copyTemporaryAudioFileToPersistentLocation(_ audioURL: URL) {
        currentRecordedAudioFilename = "\(UUID().uuidString).m4a"
        if let recordedAudioData = try? Data(contentsOf: audioURL) {
            let folderPath = recordingsFolderURL().path
            try? FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            try? recordedAudioData.write(to: recordedAudioFileURL()!)
        }
    }
}
