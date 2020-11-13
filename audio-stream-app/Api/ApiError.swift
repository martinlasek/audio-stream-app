//
//  ApiError.swift
//  audio-stream-app
//
//  Created by Martin Lasek on 13.11.20.
//

struct ApiError {
  struct Backend: Codable {
    let error: Bool
    let reason: String
  }
  
  enum Kind: String, Error {
    case noConnectionToTheServer
    case couldNotDecodeBackendResponse
    case unKnown
  }
}
