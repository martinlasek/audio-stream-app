//
//  Print+Precisely.swift
//  audio-stream-app
//
//  Created by Martin Lasek on 13.11.20.
//

/// More verbose ERROR message print function.
func printError<T>(_ type: T, _ text: String, line: Int = #line) {
  printu(.error, type, line, text)
}

/// More verbose INFO message print function.
func printInfo<T>(_ type: T, _ text: String, line: Int = #line) {
  printu(.info, type, line, text)
}

/// More verbose WARNING message print function.
func printWarning<T>(_ type: T, _ text: String, line: Int = #line) {
  printu(.warning, type, line, text)
}

/// Universal print that modifies the message to be consistent ebfore printing it.
fileprivate func printu<T>(_ kind: Kind, _ type: T, _ line: Int, _ text: String) {
  let typeName = cleanUp(type: T.self)
  print("\(kind.rawValue) Line: \(line) | \(typeName) | \(text)")
}

fileprivate enum Kind: String {
  case info = "ℹ️"
  case warning = "⚠️"
  case error = "❌"
}

/// Makes sure in case of "LocationManager" and "LocationManager.Type"
/// that "LocationManager" is returned.
fileprivate func cleanUp<T>(type: T) -> String {
  let uncleanedType = String(describing: T.self)
  let typeWordList = uncleanedType.split(separator: ".")
  return String(describing: typeWordList[0])
}
