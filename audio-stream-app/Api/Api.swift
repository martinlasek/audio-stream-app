//
//  Api.swift
//  audio-stream-app
//
//  Created by Martin Lasek on 13.11.20.
//

import Foundation

struct Api {
  private static let baseUrl = "http://www.antenne.com/services/program-info/live/antenne"

  private static func endpoint(endpoint: String = "") -> URL? {
    let link = [baseUrl, endpoint].joined(separator: "/")
    return URL(string: link)
  }

  static func hitListUrl() -> URLRequest? {
    guard let url = endpoint() else { return nil }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    return request
  }

  static func fetchHitList(completionHandler: @escaping (Result<[Hit], ApiError.Kind>) -> Void) {
    guard let reportRequest = hitListUrl() else {
      completionHandler(.failure(.noConnectionToTheServer))
      return
    }

    Api.send(request: reportRequest) { (result: Result<[Hit], ApiError.Kind>) in
      switch result {
      case .failure(let error): completionHandler(.failure(error))
      case .success(let latestHitsResponse): completionHandler(.success(latestHitsResponse))
      }
    }
  }

  // MARK: - Generic Send Function

  /// Generic Send Function. You need to specify the Result<T, Error> type to help inferring it.
  /// e.g: Api.send(request: resetRequest) { (result: Result<ResetPasswordResponse, ApiError.Kind>) in ... }
  private static func send<T: Decodable>(request: URLRequest, completionHandler: @escaping (Result<T, ApiError.Kind>) -> Void) {
    print("🌐 API Request to: \(request.url?.absoluteString ?? "nil")")
    URLSession.shared.dataTask(with: request) { data, resp, error in
      // Early return in case of error.
      if let error = error {
        print(error.localizedDescription)
        completionHandler(.failure(.noConnectionToTheServer))
        return
      }
      
      guard let data = data else {
        completionHandler(.failure(.unKnown))
        return
      }

      if let restaurant = try? JSONDecoder().decode(T.self, from: data) {
        completionHandler(.success(restaurant))
        return
      }
      
      if let backendError = try? JSONDecoder().decode(ApiError.Backend.self, from: data) {
        let error = ApiError.Kind(rawValue: backendError.reason) ?? ApiError.Kind.unKnown
        if error == .unKnown { print("❌ Unknown Error: \(backendError.reason)") }
        completionHandler(.failure(error))
        return
      }
      
      print(String(data: data, encoding: .utf8) ?? "")
      completionHandler(.failure(.couldNotDecodeBackendResponse))
    }.resume()
  }
}
