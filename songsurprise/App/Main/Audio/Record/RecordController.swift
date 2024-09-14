//
//  RecordController.swift
//  Pods-SoundWave_Example
//
//  Created by Bastien Falcou on 4/27/19.
//

import UIKit

class RecordController: UIViewController {

    enum AudioRecodingState {
        case ready
        case recording
        case recorded
        case playing
        case paused

        var buttonImage: UIImage {
            switch self {
            case .ready, .recording:
                return #imageLiteral(resourceName: "Record-Button")
            case .recorded, .paused:
                return #imageLiteral(resourceName: "Play-Button")
            case .playing:
                return #imageLiteral(resourceName: "Pause-Button")
            }
        }

        var audioVisualizationMode: AudioVisualizationView.AudioVisualizationMode {
            switch self {
            case .ready, .recording:
                return .write
            case .paused, .playing, .recorded:
                return .read
            }
        }
    }
    
    private let viewModel = ViewModel()
    private var currentState: AudioRecodingState = .ready {
        didSet {
            self.recordButton.setImage(self.currentState.buttonImage, for: .normal)
            self.audioVisualizationView.audioVisualizationMode = self.currentState.audioVisualizationMode
            self.clearButton.isHidden = self.currentState == .ready || self.currentState == .playing || self.currentState == .recording
        }
    }
    
    private lazy var recordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(recordButtonDidTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(recordButtonDidTouchUpInside), for: .touchUpInside)
        button.setImage(UIImage(named: "Record-Button"), for: .normal)
        
        return button
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleClearButton), for: .touchUpInside)
        button.setTitle("✕", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 35, weight: .semibold)
        button.isHidden = true
        
        return button
    }()
    
    private lazy var audioVisualizationView: AudioVisualizationView = {
        let view = AudioVisualizationView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 655))
        view.contentMode = .scaleToFill
        view.isUserInteractionEnabled = true
//        view.meteringLevelBarWidth = 3.00
//        view.meteringLevelBarInterItem = 2.00
//        view.gradientStartColor = .audioVisualizationPurpleGradientStart
//        view.gradientEndColor = .audioVisualizationPurpleGradientEnd
        return view
    }()
    
    private var chronometer: Chronometer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(audioVisualizationView, recordButton, clearButton)
        audioVisualizationView.constraints(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, size: .init(width: UIScreen.main.bounds.width, height: 655))

        recordButton.constraints(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 10, right: 0), size: .init(width: 100, height: 100))
        clearButton.constraints(top: nil, leading: recordButton.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 10, bottom: 20, right: 0), size: .init(width: 50, height: 50))
        recordButton.centerXconstraint(for: view)
        
        viewModel.askAudioRecordingPermission()
        self.viewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
            guard let self = self, self.audioVisualizationView.audioVisualizationMode == .write else {
                return
            }
            self.audioVisualizationView.add(meteringLevel: meteringLevel)
        }

        self.viewModel.audioDidFinish = { [weak self] in
            self?.currentState = .recorded
            self?.audioVisualizationView.stop()
        }
    }
    
    @objc
    func handleClearButton() {
        do {
            try self.viewModel.resetRecording()
            self.audioVisualizationView.reset()
            self.currentState = .ready
        } catch {
            self.showAlert(with: error)
        }
    }
    
    @objc
    func recordButtonDidTouchDown() {
        if self.currentState == .ready {
            self.viewModel.startRecording { [weak self] soundRecord, error in
                if let error = error {
                    self?.showAlert(with: error)
                    return
                }

                self?.currentState = .recording

                self?.chronometer = Chronometer()
                self?.chronometer?.start()
            }
        }
    }
    
    @objc
    func recordButtonDidTouchUpInside() {
        switch self.currentState {
        case .recording:
            self.chronometer?.stop()
            self.chronometer = nil

            self.viewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
            self.audioVisualizationView.audioVisualizationMode = .read

            do {
                try self.viewModel.stopRecording()
                self.currentState = .recorded
            } catch {
                self.currentState = .ready
                self.showAlert(with: error)
            }
        case .recorded, .paused:
            do {
                let duration = try self.viewModel.startPlaying()
                self.currentState = .playing
                self.audioVisualizationView.meteringLevels = self.viewModel.currentAudioRecord!.meteringLevels
                self.audioVisualizationView.play(for: duration)
            } catch {
                self.showAlert(with: error)
            }
        case .playing:
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        default:
            break
        }
    }
}
