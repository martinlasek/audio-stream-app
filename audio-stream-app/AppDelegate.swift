//
//  AppDelegate.swift
//  audio-stream-app
//
//  Created by Martin Lasek on 13.11.20.
//
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = PlayerVC()
    window?.makeKeyAndVisible()
    return true
  }
}
