

//import UIKit
//import SwiftAudioPlayer
//import AVFoundation
//
//class ViewController: UIViewController {
//    var selectedAudio: AudioInfo = AudioInfo(index: 0)
//    
//    var freq:[Int] = [0,0,0,0,0,0,0,0,0,0]
//    @IBOutlet weak var currentUrlLocationLabel: UILabel!
//    @IBOutlet weak var bufferProgress: UIProgressView!
//    @IBOutlet weak var scrubberSlider: UISlider!
//    
//    @IBOutlet weak var playPauseButton: UIButton!
//    @IBOutlet weak var skipBackwardButton: UIButton!
//    @IBOutlet weak var skipForwardButton: UIButton!
//    
//    @IBOutlet weak var audioSelector: UISegmentedControl!
//    @IBOutlet weak var streamButton: UIButton!
//    @IBOutlet weak var downloadButton: UIButton!
//    @IBOutlet weak var rateSlider: UISlider!
//    
//    @IBOutlet weak var rateLabel: UILabel!
//    
//    @IBOutlet weak var reverbLabel: UILabel!
//    @IBOutlet weak var reverbSlider: UISlider!
//    @IBOutlet weak var durationLabel: UILabel!
//    @IBOutlet weak var currentTimestampLabel: UILabel!
//    
//    var isDownloading: Bool = false
//    var isStreaming: Bool = false
//    var beingSeeked: Bool = false
//    var loopEnabled = false
//    
//    
//    var downloadId: UInt?
//    var durationId: UInt?
//    var bufferId: UInt?
//    var playingStatusId: UInt?
//    var queueId: UInt?
//    var elapsedId: UInt?
//
//    var duration: Double = 0.0
//    var playbackStatus: SAPlayingStatus = .paused
//    
//    var lastPlayedAudioIndex: Int?
//    
//    var isPlayable: Bool = false {
//        didSet {
//            if isPlayable {
//                playPauseButton.isEnabled = true
//                skipBackwardButton.isEnabled = true
//                skipForwardButton.isEnabled = true
//            } else {
//                playPauseButton.isEnabled = false
//                skipBackwardButton.isEnabled = false
//                skipForwardButton.isEnabled = false
//            }
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        SAPlayer.Downloader.allowUsingCellularData = true
//        SAPlayer.shared.HTTPHeaderFields = ["User-Agent": "foobar"]
//        
////        SAPlayer.shared.DEBUG_MODE = true
//        
//        isPlayable = false
//        checkIfAudioDownloaded()
//        selectAudio(atIndex: 0)
//        
////        addRandomModifiers()
//        
//        subscribeToChanges()
//    }
//    
//    func addRandomModifiers() {
//        let node = AVAudioUnitReverb()
//        SAPlayer.shared.audioModifiers.append(node)
//        node.wetDryMix = 300
//        let frequency:[Int] = [60,170,310,600,1000,3000,6000,12000,14000,16000]
//        let node2 = AVAudioUnitEQ(numberOfBands:frequency.count)
//        node2.globalGain = 1
//        for i in 0...(node2.bands.count-1) {
//            node2.bands[i].frequency  = Float(frequency[i])
//            node2.bands[i].gain       = 0
//            node2.bands[i].bypass     = false
//            node2.bands[i].filterType = .parametric
//        }
//        SAPlayer.shared.audioModifiers.append(node2)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    @IBAction func audioSelected(_ sender: Any) {
//        let selected = audioSelector.selectedSegmentIndex
//        
//        selectAudio(atIndex: selected)
//    }
//    
//    func selectAudio(atIndex i: Int) {
//        selectedAudio.setIndex(i)
//        
//        if selectedAudio.savedUrl != nil {
//            downloadButton.isEnabled = true
//            downloadButton.setTitle("Delete downloaded", for: .normal)
//            streamButton.isEnabled = false
//        } else {
//            downloadButton.isEnabled = true
//            downloadButton.setTitle("Download", for: .normal)
//            streamButton.isEnabled = true
//        }
//    }
//    
//    func checkIfAudioDownloaded() {
//        for i in 0...2 {
//            if let savedUrl = SAPlayer.Downloader.getSavedUrl(forRemoteUrl: selectedAudio.getUrl(atIndex: i)) {
//                selectedAudio.addSavedUrl(savedUrl, atIndex: i)
//            }
//        }
//    }
//    
//    func subscribeToChanges() {
//        durationId = SAPlayer.Updates.Duration.subscribe { [weak self] (duration) in
//            guard let self = self else { return }
//            self.durationLabel.text = SAPlayer.prettifyTimestamp(duration)
//            self.duration = duration
//        }
//        
//        elapsedId = SAPlayer.Updates.ElapsedTime.subscribe { [weak self] (position) in
//            guard let self = self else { return }
//            
//            self.currentTimestampLabel.text = SAPlayer.prettifyTimestamp(position)
//            
//            guard self.duration != 0 else { return }
//            
//            self.scrubberSlider.value = Float(position/self.duration)
//        }
//        
//        downloadId = SAPlayer.Updates.AudioDownloading.subscribe { [weak self] (url, progress) in
//            guard let self = self else { return }
//            guard url == self.selectedAudio.url else { return }
//            
//            if self.isDownloading {
//                DispatchQueue.main.async {
//                    UIView.performWithoutAnimation {
//                        self.downloadButton.setTitle("Cancel \(String(format: "%.2f", (progress * 100)))%", for: .normal)
//                    }
//                }
//            }
//        }
//        
//        bufferId = SAPlayer.Updates.StreamingBuffer.subscribe{ [weak self] (buffer) in
//            guard let self = self else { return }
//            
//            self.bufferProgress.progress = Float(buffer.bufferingProgress)
//            
//            if buffer.bufferingProgress >= 0.99 {
//                self.streamButton.isEnabled = false
//            } else {
//                self.streamButton.isEnabled = true
//            }
//            
//            self.isPlayable = buffer.isReadyForPlaying
//        }
//        
//        playingStatusId = SAPlayer.Updates.PlayingStatus.subscribe { [weak self] (playing) in
//            guard let self = self else { return }
//            
//            self.playbackStatus = playing
//            
//            switch playing {
//            case .playing:
//                self.isPlayable = true
//                self.playPauseButton.setTitle("Pause", for: .normal)
//                return
//            case .paused:
//                self.isPlayable = true
//                self.playPauseButton.setTitle("Play", for: .normal)
//                return
//            case .buffering:
//                self.isPlayable = false
//                self.playPauseButton.setTitle("Loading", for: .normal)
//                return
//            case .ended:
//                if !self.loopEnabled {
//                    self.isPlayable = false
//                    self.playPauseButton.setTitle("Done", for: .normal)
//                }
//                return
//            }
//        }
//        
//        queueId = SAPlayer.Updates.AudioQueue.subscribe { [weak self] forthcomingPlaybackUrl in
//            guard let self = self else { return }
//            /// we update the selected audio. this is a little contrived, but allows us to update outlets
//            if let indexFound = self.selectedAudio.getIndex(forURL: forthcomingPlaybackUrl) {
//                self.selectAudio(atIndex: indexFound)
//            }
//            
//            self.currentUrlLocationLabel.text = "\(forthcomingPlaybackUrl.absoluteString)"
//        }
//    }
//    
//    func unsubscribeFromChanges() {
//        guard let durationId = self.durationId,
//              let elapsedId = self.elapsedId,
//              let downloadId = self.downloadId,
//              let queueId = self.queueId,
//              let bufferId = self.bufferId,
//              let playingStatusId = self.playingStatusId else { return }
//        
//        SAPlayer.Updates.Duration.unsubscribe(durationId)
//        SAPlayer.Updates.ElapsedTime.unsubscribe(elapsedId)
//        SAPlayer.Updates.AudioDownloading.unsubscribe(downloadId)
//        SAPlayer.Updates.AudioQueue.unsubscribe(queueId)
//        SAPlayer.Updates.StreamingBuffer.unsubscribe(bufferId)
//        SAPlayer.Updates.PlayingStatus.unsubscribe(playingStatusId)
//    }
//    
//    
//    @IBAction func scrubberStartedSeeking(_ sender: UISlider) {
//        beingSeeked = true
//    }
//    
//    @IBAction func scrubberSeeked(_ sender: Any) {
//        let value = Double(scrubberSlider.value) * duration
//        SAPlayer.shared.seekTo(seconds: value)
//        beingSeeked = false
//    }
//    
//    
//    @IBAction func rateChanged(_ sender: Any) {
//        let speed = rateSlider.value
//        rateLabel.text = "rate: \(speed)x"
//        
//        if skipSilencesSwitch.isOn {
//            SAPlayer.Features.SkipSilences.setRateSafely(speed) // if using Skip Silences, we need use this version of setting rate to safely change the rate with the feature enabled.
//        } else {
//            SAPlayer.shared.rate = speed
//        }
//    }
//    @IBAction func reverbChanged(_ sender: Any) {
//        let reverb = reverbSlider.value
//        reverbLabel.text = "reverb: \(reverb)"
//        if let node = SAPlayer.shared.audioModifiers[1] as? AVAudioUnitReverb {
//            node.wetDryMix = reverb
//        }
//    }
//    @IBAction func queueTouched(_ sender: Any) {
//        if let savedUrl = selectedAudio.savedUrl {
//            SAPlayer.shared.queueSavedAudio(withSavedUrl: savedUrl)
//        } else {
//            SAPlayer.shared.queueRemoteAudio(withRemoteUrl: selectedAudio.url)
//        }
//        
//        print("queue: \(SAPlayer.shared.audioQueued)")
//    }
//    
//    @IBAction func downloadTouched(_ sender: Any) {
//        if !isDownloading {
//            if let savedUrl = SAPlayer.Downloader.getSavedUrl(forRemoteUrl: selectedAudio.url) {
//                SAPlayer.Downloader.deleteDownloaded(withSavedUrl: savedUrl)
//                selectedAudio.deleteSavedUrl()
//                downloadButton.setTitle("Download", for: .normal)
//                streamButton.isEnabled = true
//                isDownloading = false
//            } else {
//                downloadButton.setTitle("Cancel 0%", for: .normal)
//                isDownloading = true
//                SAPlayer.Downloader.downloadAudio(withRemoteUrl: selectedAudio.url, completion: { [weak self] (url, error) in
//                    guard let self = self else { return }
//                    guard error == nil else {
//                        DispatchQueue.main.async {
//                            self.currentUrlLocationLabel.text = "ERROR! \(error!.localizedDescription)"
//                        }
//                        return
//                    }
//                    
//                    DispatchQueue.main.async {
//                        self.currentUrlLocationLabel.text = "saved to: \(url.lastPathComponent)"
//                        self.selectedAudio.addSavedUrl(url)
//                    }
//                })
//                streamButton.isEnabled = false
//            }
//        } else {
//            SAPlayer.Downloader.cancelDownload(withRemoteUrl: selectedAudio.url)
//            downloadButton.setTitle("Download", for: .normal)
//            streamButton.isEnabled = true
//            isDownloading = false
//        }
//    }
//    
//    @IBAction func streamTouched(_ sender: Any) {
//        if !isStreaming {
//            self.currentUrlLocationLabel.text = "remote url: \(selectedAudio.url.absoluteString)"
//            if selectedAudio.index == 2 { // radio
//                SAPlayer.shared.startRemoteAudio(withRemoteUrl: selectedAudio.url, bitrate: .low, mediaInfo: selectedAudio.lockscreenInfo)
//            } else {
//                SAPlayer.shared.startRemoteAudio(withRemoteUrl: selectedAudio.url, mediaInfo: selectedAudio.lockscreenInfo)
//            }
//
//            lastPlayedAudioIndex = selectedAudio.index
//            streamButton.setTitle("Cancel streaming", for: .normal)
//            downloadButton.isEnabled = false
//            isStreaming = true
//        } else {
//            SAPlayer.shared.stopStreamingRemoteAudio()
//            streamButton.setTitle("Stream", for: .normal)
//            downloadButton.isEnabled = true
//            isStreaming = false
//        }
//    }
//    
//    @IBAction func playPauseTouched(_ sender: Any) {
//        SAPlayer.shared.togglePlayAndPause()
//    }
//    
//    @IBAction func skipBackwardTouched(_ sender: Any) {
//        SAPlayer.shared.skipBackwards()
//    }
//    
//    @IBAction func skipForwardTouched(_ sender: Any) {
//        SAPlayer.shared.skipForward()
//    }
//    @IBAction func setEqualizerValue(_ sender: Any) {
//        if let slider = sender as? UISlider{
//            print("slider of index:", slider.tag, "is changed to", slider.value)
//            freq[slider.tag] = Int(slider.value)
//            print("current frequency : ",freq)
//            if let node = SAPlayer.shared.audioModifiers[2] as? AVAudioUnitEQ{
//                for i in 0...(node.bands.count - 1){
//                    node.bands[i].gain = Float(freq[i])
//                }
//            }
//        }
//        
//    }
//    
//    @IBOutlet weak var skipSilencesSwitch: UISwitch!
//    
//    @IBAction func skipSilencesSwitched(_ sender: Any) {
//        if skipSilencesSwitch.isOn {
//            _ = SAPlayer.Features.SkipSilences.enable()
//        } else {
//            _ = SAPlayer.Features.SkipSilences.disable()
//        }
//    }
//    @IBOutlet weak var sleepSwitch: UISwitch!
//    
//    @IBAction func sleepSwitched(_ sender: Any) {
//        if sleepSwitch.isOn {
//            _ = SAPlayer.Features.SleepTimer.enable(afterDelay: 5.0)
//        } else {
//            _ = SAPlayer.Features.SleepTimer.disable()
//        }
//    }
//    
//    @IBOutlet weak var loopSwitch: UISwitch!
//    
//    @IBAction func loopSwitched(_ sender: Any) {
//        loopEnabled = loopSwitch.isOn
//        
//        if loopSwitch.isOn {
//            SAPlayer.Features.Loop.enable()
//        } else {
//            SAPlayer.Features.Loop.disable()
//        }
//        
//    }
//}

//import Foundation
//import SwiftAudioPlayer
//
//struct AudioInfo: Hashable {
//    var index: Int = 0
//    
//    var urls: [URL] = [URL(string: "https://www.fesliyanstudios.com/musicfiles/2019-04-23_-_Trusted_Advertising_-_www.fesliyanstudios.com/15SecVersion2019-04-23_-_Trusted_Advertising_-_www.fesliyanstudios.com.mp3")!,
//                       URL(string: "https://chtbl.com/track/18338/traffic.libsyn.com/secure/acquired/acquired_-_armrev_2.mp3?dest-id=376122")!,
//                       URL(string: "https://ice6.somafm.com/groovesalad-256-mp3")!]
//    
//    var url: URL {
//        switch index {
//        case 0:
//            return urls[0]
//        case 1:
//            return urls[1]
//        case 2:
//            return urls[2]
//        default:
//            return urls[0]
//        }
//    }
//    
//    var title: String {
//        switch index {
//        case 0:
//            return "Soundbite"
//        case 1:
//            return "Podcast"
//        case 2:
//            return "Radio"
//        default:
//            return "Soundbite"
//        }
//    }
//    
//    let artist: String = "SwiftAudioPlayer Sample App"
//    let releaseDate: Int = 1550790640
//    
//    var lockscreenInfo: SALockScreenInfo {
//        get {
//            return SALockScreenInfo(title: self.title, artist: self.artist, albumTitle: nil, artwork: nil, releaseDate: self.releaseDate)
//        }
//    }
//    
//    var savedUrl: URL? {
//        get {
//            return savedUrls[index]
//        }
//    }
//    
//    var savedUrls: [URL?] = [nil, nil, nil]
//    
//    mutating func addSavedUrl(_ url: URL) {
//        savedUrls[index] = url
//    }
//    
//    mutating func deleteSavedUrl() {
//        savedUrls[index] = nil
//    }
//    
//    mutating func addSavedUrl(_ url: URL, atIndex i: Int) {
//        savedUrls[i] = url
//    }
//    
//    mutating func deleteSavedUrl(atIndex i: Int) {
//        savedUrls[i] = nil
//    }
//    
//    func getUrl(atIndex i: Int) -> URL {
//        return urls[i]
//    }
//    
//    mutating func setIndex(_ i: Int) {
//        index = i
//    }
//    
//    func getIndex(forURL url: URL) -> Int? {
//        return urls.firstIndex(of: url) ?? savedUrls.firstIndex(of: url)
//    }
//}

//<?xml version="1.0" encoding="UTF-8"?>
//<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="18122" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" useTraitCollections="YES" colorMatched="YES" initialViewController="vXZ-lx-hvc">
//    <device id="retina4_7" orientation="portrait" appearance="light"/>
//    <dependencies>
//        <deployment identifier="iOS"/>
//        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="18093"/>
//        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
//    </dependencies>
//    <scenes>
//        <!--View Controller-->
//        <scene sceneID="ufC-wZ-h7g">
//            <objects>
//                <viewController id="vXZ-lx-hvc" customClass="ViewController" customModule="SwiftAudioPlayer_Example" customModuleProvider="target" sceneMemberID="viewController">
//                    <layoutGuides>
//                        <viewControllerLayoutGuide type="top" id="jyV-Pf-zRb"/>
//                        <viewControllerLayoutGuide type="bottom" id="2fi-mo-0CV"/>
//                    </layoutGuides>
//                    <view key="view" contentMode="scaleToFill" id="kh9-bI-dsS">
//                        <rect key="frame" x="0.0" y="0.0" width="375" height="667"/>
//                        <autoresizingMask key="autoresizingMask" flexibleMaxX="YES" flexibleMaxY="YES"/>
//                        <subviews>
//                            <progressView opaque="NO" contentMode="scaleToFill" verticalHuggingPriority="750" translatesAutoresizingMaskIntoConstraints="NO" id="lTK-Hd-Tl2">
//                                <rect key="frame" x="16" y="303" width="343" height="4"/>
//                                <color key="tintColor" white="0.0" alpha="0.0" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
//                                <color key="progressTintColor" red="0.46202266219999999" green="0.83828371759999998" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
//                                <color key="trackTintColor" white="0.66666666666666663" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
//                            </progressView>
//                            <slider opaque="NO" contentMode="scaleToFill" verticalCompressionResistancePriority="749" contentHorizontalAlignment="center" contentVerticalAlignment="center" minValue="0.0" maxValue="1" translatesAutoresizingMaskIntoConstraints="NO" id="w2a-RA-zmI">
//                                <rect key="frame" x="14" y="289" width="347" height="31"/>
//                                <color key="backgroundColor" white="0.0" alpha="0.0" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
//                                <color key="maximumTrackTintColor" white="0.0" alpha="0.0" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
//                                <connections>
//                                    <action selector="scrubberSeeked:" destination="vXZ-lx-hvc" eventType="touchUpInside" id="hTi-fq-lrl"/>
//                                    <action selector="scrubberSeeked:" destination="vXZ-lx-hvc" eventType="touchUpOutside" id="mFP-SW-38w"/>
//                                    <action selector="scrubberStartedSeeking:" destination="vXZ-lx-hvc" eventType="touchDown" id="UXg-Wf-fKv"/>
//                                </connections>
//                            </slider>
//                            <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="jUc-tP-CC5">
//                                <rect key="frame" x="172.5" y="233" width="30" height="30"/>
//                                <state key="normal" title="play"/>
//                                <connections>
//                                    <action selector="playPauseTouched:" destination="vXZ-lx-hvc" eventType="touchUpInside" id="Avk-K3-EZ7"/>
//                                </connections>
//                            </button>
//                            <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="tFH-sY-Xu9">
//                                <rect key="frame" x="62.5" y="233" width="30" height="30"/>
//                                <state key="normal" title="-15"/>
//                                <connections>
//                                    <action selector="skipBackwardTouched:" destination="vXZ-lx-hvc" eventType="touchUpInside" id="PCT-BE-udf"/>
//                                </connections>
//                            </button>
//                            <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="0QE-3F-a4G">
//                                <rect key="frame" x="282.5" y="233" width="30" height="30"/>
//                                <state key="normal" title="+30"/>
//                                <connections>
//                                    <action selector="skipForwardTouched:" destination="vXZ-lx-hvc" eventType="touchUpInside" id="uXv-bz-tnt"/>
//                                </connections>
//                            </button>
//                            <slider opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" value="1" minValue="0.10000000000000001" maxValue="32" translatesAutoresizingMaskIntoConstraints="NO" id="vfk-OJ-S3T">
//                                <rect key="frame" x="14" y="448" width="347" height="31"/>
//                                <connections>
//                                    <action selector="rateChanged:" destination="vXZ-lx-hvc" eventType="valueChanged" id="FDJ-jA-bm8"/>
//                                </connections>
//                            </slider>
//                            <slider opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" value="300" minValue="0.10000000149011612" maxValue="1000" translatesAutoresizingMaskIntoConstraints="NO" id="nsl-df-P21">
//                                <rect key="frame" x="14" y="381" width="347" height="31"/>
//                                <connections>
//                                    <action selector="reverbChanged:" destination="vXZ-lx-hvc" eventType="valueChanged" id="J8Q-be-35q"/>
//                                </connections>
//                            </slider>
//                            <segmentedControl opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="left" contentVerticalAlignment="top" segmentControlStyle="plain" selectedSegmentIndex="0" translatesAutoresizingMaskIntoConstraints="NO" id="joK-xi-MCo">
//                                <rect key="frame" x="16" y="60" width="343" height="32"/>
//                                <segments>
//                                    <segment title="Soundbite"/>
//                                    <segment title="Podcast"/>
//                                    <segment title="Radio"/>
//                                </segments>
//                                <connections>
//                                    <action selector="audioSelected:" destination="vXZ-lx-hvc" eventType="valueChanged" id="oYE-yq-348"/>
//                                </connections>
//                            </segmentedControl>
//                            <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="KDu-ea-kF8">
//                                <rect key="frame" x="43" y="123" width="69" height="30"/>
//                                <state key="normal" title="Download"/>
//                                <connections>
//                                    <action selector="downloadTouched:" destination="vXZ-lx-hvc" eventType="touchUpInside" id="8Jg-1C-0Ms"/>
//                                </connections>
//                            </button>
//                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="rate: 1.0x" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="yUQ-mI-ozK">
//                                <rect key="frame" x="153" y="419" width="69" height="21"/>
//                                <fontDescription key="fontDescription" type="system" pointSize="17"/>
//                                <nil key="textColor"/>
//                                <nil key="highlightedColor"/>
//                            </label>
//                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="0:00" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="j3w-gr-HzF">
//                                <rect key="frame" x="16" y="280" width="27" height="15"/>
//                                <fontDescription key="fontDescription" type="system" pointSize="12"/>
//                                <nil key="textColor"/>
//                                <nil key="highlightedColor"/>
//                            </label>
//                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="100:00" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="Urj-Dv-41y">
//                                <rect key="frame" x="319" y="280" width="40" height="15"/>
//                                <fontDescription key="fontDescription" type="system" pointSize="12"/>
//                                <nil key="textColor"/>
//                                <nil key="highlightedColor"/>
//                            </label>
//                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="remote url: " textAlignment="center" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="1IX-z5-wWx">
//                                <rect key="frame" x="16" y="190" width="343" height="16"/>
//                                <fontDescription key="fontDescription" type="system" pointSize="13"/>
//                                <nil key="textColor"/>
//                                <nil key="highlightedColor"/>
//                            </label>
//                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="reverb: 300.0" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="y5i-MZ-Qat">
//                                <rect key="frame" x="136.5" y="352" width="102" height="21"/>
//                                <fontDescription key="fontDescription" type="system" pointSize="17"/>
//                                <nil key="textColor"/>
//                                <nil key="highlightedColor"/>
//                            </label>
//                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Skip Silences" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="M2y-FP-H1D">
//                                <rect key="frame" x="89" y="504" width="101" height="21"/>
//                                <fontDescription key="fontDescription" type="system" pointSize="17"/>
//                                <nil key="textColor"/>
//                                <nil key="highlightedColor"/>
//                            </label>
//                            <switch opaque="NO" contentMode="scaleToFill" horizontalHuggingPriority="750" verticalHuggingPriority="750" contentHorizontalAlignment="center" contentVerticalAlignment="center" translatesAutoresizingMaskIntoConstraints="NO" id="2cn-E5-TeQ">
//                                <rect key="frame" x="226" y="499" width="51" height="31"/>
//                                <connections>
//                                    <action selector="skipSilencesSwitched:" destination="vXZ-lx-hvc" eventType="valueChanged" id="p7X-Y8-7hO"/>
//                                </connections>
//                            </switch>
//                            <switch opaque="NO" contentMode="scaleToFill" horizontalHuggingPriority="750" verticalHuggingPriority="750" contentHorizontalAlignment="center" contentVerticalAlignment="center" translatesAutoresizingMaskIntoConstraints="NO" id="IGe-aU-Y6D">
//                                <rect key="frame" x="226" y="540" width="51" height="31"/>
//                                <connections>
//                                    <action selector="sleepSwitched:" destination="vXZ-lx-hvc" eventType="valueChanged" id="noa-m8-VHy"/>
//                                </connections>
//                            </switch>
//                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Sleep After 5 s" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="vf6-kr-yWa">
//                                <rect key="frame" x="83" y="545" width="112" height="21"/>
//                                <fontDescription key="fontDescription" type="system" pointSize="17"/>
//                                <nil key="textColor"/>
//                                <nil key="highlightedColor"/>
//                            </label>
//                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Loop" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="JOr-pf-CKN">
//                                <rect key="frame" x="152" y="588" width="38" height="21"/>
//                                <fontDescription key="fontDescription" type="system" pointSize="17"/>
//                                <nil key="textColor"/>
//                                <nil key="highlightedColor"/>
//                            </label>
//                            <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="pVf-cJ-9ca">
//                                <rect key="frame" x="164.5" y="123" width="46" height="30"/>
//                                <state key="normal" title="Queue"/>
//                                <connections>
//                                    <action selector="queueTouched:" destination="vXZ-lx-hvc" eventType="touchUpInside" id="qRj-oT-AV1"/>
//                                </connections>
//                            </button>
//                            <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="6d9-Bc-hIz">
//                                <rect key="frame" x="282" y="123" width="49" height="30"/>
//                                <state key="normal" title="Stream"/>
//                                <connections>
//                                    <action selector="streamTouched:" destination="vXZ-lx-hvc" eventType="touchUpInside" id="AXY-N7-87Y"/>
//                                </connections>
//                            </button>
//                            <switch opaque="NO" contentMode="scaleToFill" horizontalHuggingPriority="750" verticalHuggingPriority="750" contentHorizontalAlignment="center" contentVerticalAlignment="center" translatesAutoresizingMaskIntoConstraints="NO" id="cfU-Rp-Kqf">
//                                <rect key="frame" x="226" y="583" width="51" height="31"/>
//                                <connections>
//                                    <action selector="loopSwitched:" destination="vXZ-lx-hvc" eventType="valueChanged" id="psj-Vs-9BI"/>
//                                </connections>
//                            </switch>
//                        </subviews>
//                        <color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
//                        <constraints>
//                            <constraint firstItem="nsl-df-P21" firstAttribute="top" secondItem="y5i-MZ-Qat" secondAttribute="bottom" constant="8" id="0aM-Sz-J9k"/>
//                            <constraint firstItem="lTK-Hd-Tl2" firstAttribute="leading" secondItem="kh9-bI-dsS" secondAttribute="leading" constant="16" id="1wb-IW-jYz"/>
//                            <constraint firstItem="j3w-gr-HzF" firstAttribute="leading" secondItem="lTK-Hd-Tl2" secondAttribute="leading" id="26c-ZJ-768"/>
//                            <constraint firstItem="JOr-pf-CKN" firstAttribute="top" secondItem="vf6-kr-yWa" secondAttribute="bottom" constant="22" id="4UI-XL-M9D"/>
//                            <constraint firstItem="jUc-tP-CC5" firstAttribute="top" secondItem="KDu-ea-kF8" secondAttribute="bottom" constant="80" id="5sT-An-9vw"/>
//                            <constraint firstItem="6d9-Bc-hIz" firstAttribute="leading" relation="greaterThanOrEqual" secondItem="KDu-ea-kF8" secondAttribute="trailing" constant="8" symbolic="YES" id="60t-zV-EiY"/>
//                            <constraint firstItem="2cn-E5-TeQ" firstAttribute="centerY" secondItem="M2y-FP-H1D" secondAttribute="centerY" id="6QX-Ru-ZbO"/>
//                            <constraint firstItem="joK-xi-MCo" firstAttribute="leading" secondItem="lTK-Hd-Tl2" secondAttribute="leading" id="7KA-Mg-HFD"/>
//                            <constraint firstItem="vfk-OJ-S3T" firstAttribute="trailing" secondItem="lTK-Hd-Tl2" secondAttribute="trailing" id="8PP-Pp-1Hc"/>
//                            <constraint firstItem="joK-xi-MCo" firstAttribute="trailing" secondItem="lTK-Hd-Tl2" secondAttribute="trailing" id="AH1-Uu-eLB"/>
//                            <constraint firstItem="joK-xi-MCo" firstAttribute="top" secondItem="jyV-Pf-zRb" secondAttribute="bottom" constant="60" id="Ba7-nd-oCD"/>
//                            <constraint firstItem="pVf-cJ-9ca" firstAttribute="centerY" secondItem="KDu-ea-kF8" secondAttribute="centerY" id="Cma-VU-v2t"/>
//                            <constraint firstItem="Urj-Dv-41y" firstAttribute="centerY" secondItem="j3w-gr-HzF" secondAttribute="centerY" id="Fvd-7V-Rr8"/>
//                            <constraint firstItem="1IX-z5-wWx" firstAttribute="leading" secondItem="joK-xi-MCo" secondAttribute="leading" id="GeX-7f-jzu"/>
//                            <constraint firstItem="0QE-3F-a4G" firstAttribute="leading" relation="greaterThanOrEqual" secondItem="jUc-tP-CC5" secondAttribute="trailing" constant="8" symbolic="YES" id="JP5-yW-eVB"/>
//                            <constraint firstItem="cfU-Rp-Kqf" firstAttribute="leading" secondItem="JOr-pf-CKN" secondAttribute="trailing" constant="36" id="JxU-kl-pkL"/>
//                            <constraint firstItem="yUQ-mI-ozK" firstAttribute="top" secondItem="w2a-RA-zmI" secondAttribute="bottom" constant="100" id="K1K-8N-SpD"/>
//                            <constraint firstItem="IGe-aU-Y6D" firstAttribute="centerY" secondItem="vf6-kr-yWa" secondAttribute="centerY" id="K1s-td-R7b"/>
//                            <constraint firstItem="vf6-kr-yWa" firstAttribute="leading" secondItem="kh9-bI-dsS" secondAttribute="leading" constant="83" id="M0b-b2-UnQ"/>
//                            <constraint firstItem="vfk-OJ-S3T" firstAttribute="leading" secondItem="lTK-Hd-Tl2" secondAttribute="leading" id="NOY-IO-NIJ"/>
//                            <constraint firstItem="tFH-sY-Xu9" firstAttribute="centerY" secondItem="jUc-tP-CC5" secondAttribute="centerY" id="Rre-EY-kVY"/>
//                            <constraint firstItem="KDu-ea-kF8" firstAttribute="leading" secondItem="kh9-bI-dsS" secondAttribute="leading" constant="43" id="SRU-sX-z5b"/>
//                            <constraint firstItem="cfU-Rp-Kqf" firstAttribute="centerY" secondItem="JOr-pf-CKN" secondAttribute="centerY" id="Tox-y4-XVg"/>
//                            <constraint firstItem="w2a-RA-zmI" firstAttribute="trailing" secondItem="lTK-Hd-Tl2" secondAttribute="trailing" id="Vki-IZ-AdN"/>
//                            <constraint firstItem="lTK-Hd-Tl2" firstAttribute="top" secondItem="j3w-gr-HzF" secondAttribute="bottom" constant="8" id="Wwx-Uo-yIC"/>
//                            <constraint firstItem="IGe-aU-Y6D" firstAttribute="leading" secondItem="vf6-kr-yWa" secondAttribute="trailing" constant="31" id="XpW-wP-Iyh"/>
//                            <constraint firstItem="vf6-kr-yWa" firstAttribute="top" secondItem="M2y-FP-H1D" secondAttribute="bottom" constant="20" id="Y8L-El-ycq"/>
//                            <constraint firstItem="nsl-df-P21" firstAttribute="leading" secondItem="vfk-OJ-S3T" secondAttribute="leading" id="a5C-nZ-8Jc"/>
//                            <constraint firstItem="yUQ-mI-ozK" firstAttribute="centerX" secondItem="kh9-bI-dsS" secondAttribute="centerX" id="a66-h4-WVf"/>
//                            <constraint firstItem="Urj-Dv-41y" firstAttribute="trailing" secondItem="lTK-Hd-Tl2" secondAttribute="trailing" id="aKt-EV-Bwd"/>
//                            <constraint firstItem="tFH-sY-Xu9" firstAttribute="top" secondItem="1IX-z5-wWx" secondAttribute="bottom" constant="27" id="bIq-V0-Sac"/>
//                            <constraint firstItem="M2y-FP-H1D" firstAttribute="top" secondItem="vfk-OJ-S3T" secondAttribute="bottom" constant="26" id="bsl-hj-xUt"/>
//                            <constraint firstItem="tFH-sY-Xu9" firstAttribute="leading" secondItem="kh9-bI-dsS" secondAttribute="leading" constant="62.5" id="cH6-q6-Lel"/>
//                            <constraint firstItem="yUQ-mI-ozK" firstAttribute="top" secondItem="nsl-df-P21" secondAttribute="bottom" constant="8" id="cKV-wk-6P9"/>
//                            <constraint firstItem="jUc-tP-CC5" firstAttribute="centerX" secondItem="kh9-bI-dsS" secondAttribute="centerX" id="cgM-Nj-yit"/>
//                            <constraint firstItem="JOr-pf-CKN" firstAttribute="leading" secondItem="kh9-bI-dsS" secondAttribute="leading" constant="152" id="cgd-E2-XpJ"/>
//                            <constraint firstItem="KDu-ea-kF8" firstAttribute="top" secondItem="joK-xi-MCo" secondAttribute="bottom" constant="32" id="dLw-rF-Pfb"/>
//                            <constraint firstItem="w2a-RA-zmI" firstAttribute="leading" secondItem="lTK-Hd-Tl2" secondAttribute="leading" id="daz-b0-eCC"/>
//                            <constraint firstItem="jUc-tP-CC5" firstAttribute="leading" relation="greaterThanOrEqual" secondItem="tFH-sY-Xu9" secondAttribute="trailing" constant="8" symbolic="YES" id="fS9-Ce-4ph"/>
//                            <constraint firstItem="Urj-Dv-41y" firstAttribute="leading" relation="greaterThanOrEqual" secondItem="j3w-gr-HzF" secondAttribute="trailing" constant="8" symbolic="YES" id="fu0-ZZ-rj9"/>
//                            <constraint firstAttribute="trailing" secondItem="lTK-Hd-Tl2" secondAttribute="trailing" constant="16" id="gdg-7Y-7la"/>
//                            <constraint firstAttribute="trailing" secondItem="1IX-z5-wWx" secondAttribute="trailing" constant="16" id="hHM-jO-RZd"/>
//                            <constraint firstItem="pVf-cJ-9ca" firstAttribute="centerX" secondItem="joK-xi-MCo" secondAttribute="centerX" id="lOM-Fa-KdR"/>
//                            <constraint firstItem="2cn-E5-TeQ" firstAttribute="leading" secondItem="M2y-FP-H1D" secondAttribute="trailing" constant="36" id="laG-3h-LI7"/>
//                            <constraint firstItem="6d9-Bc-hIz" firstAttribute="top" secondItem="joK-xi-MCo" secondAttribute="bottom" constant="32" id="m9s-An-IWV"/>
//                            <constraint firstItem="vfk-OJ-S3T" firstAttribute="top" secondItem="yUQ-mI-ozK" secondAttribute="bottom" constant="8" id="oaW-rr-UVN"/>
//                            <constraint firstItem="nsl-df-P21" firstAttribute="trailing" secondItem="vfk-OJ-S3T" secondAttribute="trailing" id="r5e-Wq-dqV"/>
//                            <constraint firstItem="y5i-MZ-Qat" firstAttribute="centerX" secondItem="nsl-df-P21" secondAttribute="centerX" id="reC-GA-ZgT"/>
//                            <constraint firstAttribute="trailing" secondItem="0QE-3F-a4G" secondAttribute="trailing" constant="62.5" id="tg1-gr-hdd"/>
//                            <constraint firstItem="M2y-FP-H1D" firstAttribute="leading" secondItem="kh9-bI-dsS" secondAttribute="leading" constant="89" id="vcF-gP-oe0"/>
//                            <constraint firstAttribute="trailing" secondItem="6d9-Bc-hIz" secondAttribute="trailing" constant="44" id="vtN-y4-iqp"/>
//                            <constraint firstItem="0QE-3F-a4G" firstAttribute="centerY" secondItem="jUc-tP-CC5" secondAttribute="centerY" id="xDi-tj-bBF"/>
//                            <constraint firstItem="lTK-Hd-Tl2" firstAttribute="top" secondItem="jUc-tP-CC5" secondAttribute="bottom" constant="40" id="ytQ-s4-kJm"/>
//                            <constraint firstItem="w2a-RA-zmI" firstAttribute="centerY" secondItem="lTK-Hd-Tl2" secondAttribute="centerY" constant="-1" id="zHt-h3-4ig"/>
//                        </constraints>
//                    </view>
//                    <connections>
//                        <outlet property="audioSelector" destination="joK-xi-MCo" id="GmY-Xg-be0"/>
//                        <outlet property="bufferProgress" destination="lTK-Hd-Tl2" id="54k-by-qb2"/>
//                        <outlet property="currentTimestampLabel" destination="j3w-gr-HzF" id="5Lh-aS-pat"/>
//                        <outlet property="currentUrlLocationLabel" destination="1IX-z5-wWx" id="MuO-fF-ZxL"/>
//                        <outlet property="downloadButton" destination="KDu-ea-kF8" id="5o4-1h-y06"/>
//                        <outlet property="durationLabel" destination="Urj-Dv-41y" id="mIq-eh-int"/>
//                        <outlet property="loopSwitch" destination="cfU-Rp-Kqf" id="wTZ-Sr-mV4"/>
//                        <outlet property="playPauseButton" destination="jUc-tP-CC5" id="e9C-zV-A1B"/>
//                        <outlet property="rateLabel" destination="yUQ-mI-ozK" id="Dx4-lO-A1B"/>
//                        <outlet property="rateSlider" destination="vfk-OJ-S3T" id="mNc-ET-aNM"/>
//                        <outlet property="reverbLabel" destination="y5i-MZ-Qat" id="8YR-mc-GFA"/>
//                        <outlet property="reverbSlider" destination="nsl-df-P21" id="BKt-Hb-akj"/>
//                        <outlet property="scrubberSlider" destination="w2a-RA-zmI" id="VbI-tT-lbc"/>
//                        <outlet property="skipBackwardButton" destination="tFH-sY-Xu9" id="LwM-2S-m6F"/>
//                        <outlet property="skipForwardButton" destination="0QE-3F-a4G" id="cQ7-b7-pW7"/>
//                        <outlet property="skipSilencesSwitch" destination="2cn-E5-TeQ" id="TRI-IT-YJT"/>
//                        <outlet property="sleepSwitch" destination="IGe-aU-Y6D" id="BZn-9C-hOk"/>
//                        <outlet property="streamButton" destination="6d9-Bc-hIz" id="DZe-ga-3RV"/>
//                    </connections>
//                </viewController>
//                <placeholder placeholderIdentifier="IBFirstResponder" id="x5A-6p-PRh" sceneMemberID="firstResponder"/>
//            </objects>
//            <point key="canvasLocation" x="132" y="103.89805097451276"/>
//        </scene>
//    </scenes>
//</document>
