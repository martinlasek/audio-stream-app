//
//  PlayerDispatcher.swift
//  audio-stream-app
//
//  Created by Martin Lasek on 13.11.20.
//

import AVFoundation

protocol PlayerDispatcherDelegate: class {
  func metaInfoDidUpdate()
}

final class PlayerDispatcher: NSObject {
  private var audioPlayer: AVPlayer?
  private var audioItem: AVPlayerItem?
  private let streamURL = URL(string: "http://stream.antenne.com/antenne-nds-80er/mp3-128/iPhoneApp")
  weak var delegate: PlayerDispatcherDelegate?

  override init() {
    try? AVAudioSession.sharedInstance().setCategory(.playback)
  }

  // MARK: - Public

  func findLatestTrack(hitName: String, hitList: [Hit]) -> Track? {
    guard
      let hit = hitList.first(where: { $0.name == hitName }),
      let latestHistoryEntry = hit.playHistories.first
    else {
      return nil
    }

    return latestHistoryEntry.track
  }

  func streamAudio() {
    guard let url = streamURL else { return }

    audioItem = AVPlayerItem(url: url)
    let metaDataOutput = AVPlayerItemMetadataOutput()
    metaDataOutput.setDelegate(self, queue: .main)
    audioItem?.add(metaDataOutput)

    audioPlayer = AVPlayer(playerItem: audioItem)
    audioPlayer?.play()
  }

  func pauseStreaming() {
    audioPlayer?.pause()
  }

  // MARK: - Private

  private func shouldObserversUpdateMetaInfo(determinedFrom metaItem: AVMetadataItem) -> Bool {
    guard let metaString = metaItem.stringValue else { return false }
    printInfo(self, metaString)
    return metaString != "Antenne Niedersachsen - 80er"
  }
}

extension PlayerDispatcher: AVPlayerItemMetadataOutputPushDelegate {
  func metadataOutput(
    _ output: AVPlayerItemMetadataOutput,
    didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
    from track: AVPlayerItemTrack?
  ) {

    guard let latestMetaInfo = groups.first?.items.first else {
      printWarning(self, "Meta info was empty.")
      return
    }

    guard let delegate = delegate else {
      printWarning(self, "No delegate assigned.")
      return
    }

    if shouldObserversUpdateMetaInfo(determinedFrom: latestMetaInfo) {
      delegate.metaInfoDidUpdate()
    }
  }
}
