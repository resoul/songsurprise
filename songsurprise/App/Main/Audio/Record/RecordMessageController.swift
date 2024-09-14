//
//  RecordMessageController.swift
//  Pods-SoundWave_Example
//
//  Created by Bastien Falcou on 4/27/19.
//

import UIKit

class RecordMessageController: UIViewController {
    
    private lazy var waveformImageView = UIImageView()
    private lazy var playbackWaveformImageView = UIImageView()
    
    private let waveformImageDrawer = WaveformImageDrawer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(waveformImageView)
        view.addSubview(playbackWaveformImageView)
        waveformImageView.constraints(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 100))
        playbackWaveformImageView.constraints(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 100))
        
        do {
            let endpoint = try supabase.storage.from("audio").getPublicURL(path: "Rise.Up.mp3")
            StorageManager.shared.getAudioFile(endpoint: endpoint) { result in
                switch result {
                case .success(let url):
                    DispatchQueue.main.async {
                        self.updateWaveformImages(audioURL: url)
                    }
                    break
                case .failure(_):
                    break
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func shuffleProgressUIKit() {
        // In a real app, progress would come from your player.
        // Since there is various ways to play audio, eg AVPlayer,
        // the purpose of this example here is only to show how one
        // might visualize the progress, not how to calculate it.
        let progress = Double.random(in: 0...1)

        // Typically, this also does not need to be animated if your
        // progress updates come in at a high enough frequency
        // (every 0.1s for instance).
        updateProgressWaveform(progress)
    }
    
    private func updateWaveformImages(audioURL: URL) {
        Task {
            let image = try await waveformImageDrawer.waveformImage(fromAudioAt: audioURL, with: .init(size: playbackWaveformImageView.bounds.size, style: .filled(.darkGray)))

            DispatchQueue.main.async {
                self.waveformImageView.image = image
                self.playbackWaveformImageView.image = image.withTintColor(.red, renderingMode: .alwaysTemplate)
                self.shuffleProgressUIKit()
            }
        }
    }
    
    private func updateProgressWaveform(_ progress: Double) {
        let fullRect = playbackWaveformImageView.bounds
        let newWidth = Double(fullRect.size.width) * progress

        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))

        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path

        playbackWaveformImageView.layer.mask = maskLayer
    }
}
