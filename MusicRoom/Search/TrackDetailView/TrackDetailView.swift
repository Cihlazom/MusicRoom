//
//  TrackDetailView.swift
//  MusicRoom
//
//  Created by Vladislav on 16.04.2022.
//

import UIKit
import SDWebImage
import AVKit

protocol TrackMovingDelegate {
    func moveBack() -> SearchViewModel.Cell?
    func moveForward() -> SearchViewModel.Cell?

}

class TrackDetailView: UIView {
    
    @IBOutlet weak var miniTrackView: UIView!
    @IBOutlet weak var miniForwardButton: UIButton!
    @IBOutlet weak var maximizedStackView: UIStackView!
    @IBOutlet weak var miniTrackTitle: UILabel!
    @IBOutlet weak var miniTrackImage: UIImageView!
    @IBOutlet weak var miniPlayPauseButton: UIButton!
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    let player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    var delegate: TrackMovingDelegate?
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    private let smallImageConfig = UIImage.SymbolConfiguration(pointSize: 30)
    private let largeImageConfig = UIImage.SymbolConfiguration(pointSize: 70, weight: .ultraLight)

    
    override func awakeFromNib() {
        super.awakeFromNib()

        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        setupGestures()
    }
    
    //MARK: - Setup
    
    func set(viewModel: SearchViewModel.Cell) {
        volumeSlider.value = 0.2
        trackTitleLabel.text = viewModel.trackName
        miniTrackTitle.text = viewModel.trackName
        authorLabel.text = viewModel.artistName
        playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: largeImageConfig), for: .normal)
        miniPlayPauseButton.setImage(UIImage(systemName: "pause.circle", withConfiguration: smallImageConfig), for: .normal)
        monitorStartTime()
        observePlayerCurrentTime()
        let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100", with: "600")
        guard let url = URL(string: string600 ?? "") else {return}
        trackImageView.sd_setImage(with: url)
        miniTrackImage.sd_setImage(with: url)
        playTrack(previewUrl: viewModel.previewUrl)
    }
    
    private func setupGestures() {
        miniTrackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximized)))
        miniTrackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanMaximized)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }
    
    private func playTrack(previewUrl: String?) {
        guard let url = URL(string: previewUrl ?? "") else {return}
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.volume = 0.2
        player.play()
    }
    
    //MARK: - Gestures
    
    @objc private func handleTapMaximized() {
        self.tabBarDelegate?.maximizeTrackDetails(viewModel: nil)
    }
    
    @objc private func handlePanMaximized(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            handlePanChange(gesture: gesture)
        case .ended:
            handlePanEnded(gesture: gesture)
        default:
            break
        }
    }
    
    private func handlePanChange(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 + translation.y / 200
        self.miniTrackView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velosity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.transform = .identity
            if translation.y < -200 || velosity.y < -500 {
                self.tabBarDelegate?.maximizeTrackDetails(viewModel: nil)
            } else {
                self.miniTrackView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        }
    }
    
    @objc private func handleDismiss(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self.superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: self.superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
                self.maximizedStackView.transform = .identity
                if translation.y > 50 {
                    self.tabBarDelegate?.minimizeTrackDetails()
                }
            }
        default:
            break
        }
    }
    
    //MARK: - Time
    
    private func monitorStartTime() {
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeImageView()
        }
    }
    
    private func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTimeLabel.text = time.toString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationTimeText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toString()
            self?.durationLabel.text = currentDurationTimeText
            self?.updateCurrentTimeSlider()
        }
    }
    
    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        currentTimeSlider.value = Float(percentage)
    }
    
    //MARK: - Animations
    
    private func enlargeImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.trackImageView.transform = .identity
        }
    }
    
    private func reduceImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            let scale: CGFloat = 0.8
            self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    //MARK: - Actions
    
    @IBAction func handleCurrentTimerSlider(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        player.volume = volumeSlider.value
    }
    
    @IBAction func dragDownButtonTapped(_ sender: Any) {
        self.tabBarDelegate?.minimizeTrackDetails()
    }
    
    @IBAction func prevTrackButton(_ sender: Any) {
        let temp = delegate?.moveBack()
        guard let cellViewModel = temp else {return}
        self.set(viewModel: cellViewModel)
    }
    
    @IBAction func nextTrackButton(_ sender: Any) {
        guard let cellViewModel = delegate?.moveForward() else {return}
        self.set(viewModel: cellViewModel)
    }
    
    @IBAction func playPauseTapped(_ sender: Any) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: largeImageConfig), for: .normal)
            miniPlayPauseButton.setImage(UIImage(systemName: "pause.circle", withConfiguration: smallImageConfig), for: .normal)
            enlargeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: largeImageConfig), for: .normal)
            miniPlayPauseButton.setImage(UIImage(systemName: "play.circle", withConfiguration: smallImageConfig), for: .normal)
            reduceImageView()
        }
    }
}
