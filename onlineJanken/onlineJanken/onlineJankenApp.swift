//
//  onlineJankenApp.swift
//  onlineJanken
//
//  Created by Yo Sato on 31/07/2024.
//

import SwiftUI
import FirebaseCore
import jankenModels

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct onlineJankenApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authService=AuthService()
    @StateObject var dataService=DataService()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authService).environmentObject(dataService)
        }
    }
}
