//
//  Hit.swift
//  audio-stream-app
//
//  Created by Martin Lasek on 13.11.20.
//

struct Hit: Decodable {
  let id: Int
  let name: String
  let playHistories: [PlayHistory]
}

struct PlayHistory: Decodable {
  let id: Int
  let track: Track
}

struct Track: Decodable {
  let title: String?
  let artist: String?
  let itunesCoverMedium: String?

  let id: Int?
  let creationTime: Int?
  let coverUrlSmall: String?
  let coverUrlMedium: String?
  let coverUrlBig: String?
  let googleShopUrl: String?
  let itunesShopUrl: String?
  let type: String?
  let itunesPreview: String?
  let itunesCoverSmall: String?
  let itunesCover: String?
  let amznShopUrl: String?
  let amznPreview: String?
  let amznCoverSmall: String?
  let amznCoverMedium: String?
  let amznCover: String?
}
