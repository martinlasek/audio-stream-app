//
//  PlayerVC.swift
//  audio-stream-app
//
//  Created by Martin Lasek on 13.11.20.
//

import UIKit

final class PlayerVC: UIViewController {
  private let backgroundImageIV = AsyncImageView()
  private let blurView = UIVisualEffectView(
    effect: UIBlurEffect(style: .systemMaterialDark)
  )

  private let latestSongCoverIV = AsyncImageView()
  private let defaultImage = UIImage(systemName: "music.note")
  private let latestSongTitleLabel = UILabel()
  private let latestSongArtistLabel = UILabel()

  private let playImage = UIImage(systemName: "play.fill")
  private let pauseImage = UIImage(systemName: "pause.fill")
  private let playPauseButton = UIButton(type: .system)
  private var isPlaying = true

  private let playerDispatcher = PlayerDispatcher()
  private var currentTrack: Track?

  override func viewDidLoad() {
    super.viewDidLoad()
    playerDispatcher.delegate = self
    setupView()
    fetchLatestTrackAndStartStream()
  }

  // MARK: - Setup View

  private func setupView() {
    setupBackground()
    setupLatestSongCoverIV()
    setupLatestSongTitle()
    setupLatestSongArtist()
    setupPlayPauseButton()
  }

  private func setupBackground() {
    view.backgroundColor = .black

    view.addSubview(backgroundImageIV)
    backgroundImageIV.translatesAutoresizingMaskIntoConstraints = false
    let top = backgroundImageIV.topAnchor.constraint(equalTo: view.topAnchor)
    let leading = backgroundImageIV.leadingAnchor.constraint(equalTo: view.leadingAnchor)
    let bottom = backgroundImageIV.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    let trailing = backgroundImageIV.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    NSLayoutConstraint.activate([top, leading, bottom, trailing])

    backgroundImageIV.contentMode = .scaleAspectFill

    view.addSubview(blurView)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    let bTop = blurView.topAnchor.constraint(equalTo: backgroundImageIV.topAnchor)
    let bLeading = blurView.leadingAnchor.constraint(equalTo: backgroundImageIV.leadingAnchor)
    let bBottom = blurView.bottomAnchor.constraint(equalTo: backgroundImageIV.bottomAnchor)
    let bTrailing = blurView.trailingAnchor.constraint(equalTo: backgroundImageIV.trailingAnchor)
    NSLayoutConstraint.activate([bTop, bLeading, bBottom, bTrailing])
  }

  private func setupLatestSongCoverIV() {
    view.addSubview(latestSongCoverIV)
    latestSongCoverIV.translatesAutoresizingMaskIntoConstraints = false
    let centerY = latestSongCoverIV.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50)
    let centerX = latestSongCoverIV.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    let width = latestSongCoverIV.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/2)
    let height = latestSongCoverIV.heightAnchor.constraint(equalTo: latestSongCoverIV.widthAnchor)
    NSLayoutConstraint.activate([centerY, centerX, width, height])

    latestSongCoverIV.image = defaultImage
    latestSongCoverIV.tintColor = .white
    latestSongCoverIV.contentMode = .scaleAspectFill
    latestSongCoverIV.layer.borderColor = UIColor.white.cgColor
    latestSongCoverIV.layer.cornerRadius = 16
    latestSongCoverIV.layer.borderWidth = 2
    latestSongCoverIV.clipsToBounds = true
  }

  private func setupLatestSongTitle() {
    view.addSubview(latestSongTitleLabel)
    latestSongTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    let top = latestSongTitleLabel.centerYAnchor.constraint(equalTo: latestSongCoverIV.bottomAnchor, constant: 30)
    let leading = latestSongTitleLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
    let trailing = latestSongTitleLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
    NSLayoutConstraint.activate([top, leading, trailing])

    latestSongTitleLabel.text = "loading..."
    latestSongTitleLabel.textAlignment = .center
    latestSongTitleLabel.textColor = .white
    latestSongTitleLabel.font = .systemFont(ofSize: 22)
  }

  private func setupLatestSongArtist() {
    view.addSubview(latestSongArtistLabel)
    latestSongArtistLabel.translatesAutoresizingMaskIntoConstraints = false
    let top = latestSongArtistLabel.centerYAnchor.constraint(equalTo: latestSongTitleLabel.bottomAnchor, constant: 15)
    let leading = latestSongArtistLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
    let trailing = latestSongArtistLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
    NSLayoutConstraint.activate([top, leading, trailing])

    latestSongArtistLabel.textAlignment = .center
    latestSongArtistLabel.textColor = .white
    latestSongArtistLabel.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
  }

  private func setupPlayPauseButton() {
    view.addSubview(playPauseButton)
    playPauseButton.translatesAutoresizingMaskIntoConstraints = false
    let top = playPauseButton.topAnchor.constraint(equalTo: latestSongArtistLabel.bottomAnchor, constant: 75)
    let centerX = playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    let width = playPauseButton.widthAnchor.constraint(equalToConstant: 50)
    let height = playPauseButton.heightAnchor.constraint(equalTo: playPauseButton.widthAnchor)
    NSLayoutConstraint.activate([top, centerX, width, height])

    playPauseButton.setImage(pauseImage, for: .normal)
    playPauseButton.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
    playPauseButton.tintColor = .white
    playPauseButton.layer.cornerRadius = 50/2
    playPauseButton.layer.borderWidth = 2
    playPauseButton.layer.borderColor = UIColor.white.cgColor
  }

  // MARK: - Logic

  private func fetchLatestTrackAndStartStream() {
    Api.fetchHitList { response in
      DispatchQueue.main.async {
        switch response {
        case .failure(let error): printError(self, error.localizedDescription)
        case .success(let response):
          self.updateLocalTrack(from: response)
          self.startStreaming()
        }
      }
    }
  }

  private func updateLocalTrack(from response: [Hit]) {
    guard let track = playerDispatcher.findLatestTrack(hitName: "Z80er", hitList: response) else {
      printError(self, "Could not find latest Track in PlayHistory of: Z80er")
      return
    }

    currentTrack = track

    if let urlString = track.itunesCoverMedium, let url = URL(string: urlString) {
      backgroundImageIV.loadImage(from: url)
      latestSongCoverIV.loadImage(from: url)
    }

    latestSongTitleLabel.text = track.title
    latestSongArtistLabel.text = track.artist
  }

  private func startStreaming() {
    guard currentTrack != nil else {
      printWarning(self, "Current track was nil.")
      return
    }
    playerDispatcher.streamAudio()
  }

  private func pauseStreaming() {
    playerDispatcher.pauseStreaming()
  }

  private func fetchLatestTrackMetaInfo() {
    Api.fetchHitList { response in
      DispatchQueue.main.async {
        switch response {
        case .failure(let error): printError(self, error.localizedDescription)
        case .success(let response): self.updateLocalTrack(from: response)
        }
      }
    }
  }

  // MARK: - Action

  @objc private func playPauseAction() {
    isPlaying.toggle()

    switch isPlaying {
    case true:
      playPauseButton.setImage(pauseImage, for: .normal)
      startStreaming()
    case false:
      playPauseButton.setImage(playImage, for: .normal)
      pauseStreaming()
    }
  }
}

extension PlayerVC: PlayerDispatcherDelegate {
  func metaInfoDidUpdate() {
    fetchLatestTrackMetaInfo()
  }
}
