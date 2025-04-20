//
//  Hindu_CalendarApp.swift
//  Hindu Calendar
//
//  Created by Sudhanva Acharya on 01/03/25.
//

import SwiftUI
import AVFoundation

@main
struct Hindu_CalendarApp: App {
    @AppStorage("omChantEnabled") private var omChantEnabled = true
    @AppStorage("omChantVolume") private var omChantVolume = 0.5
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .task {
                    // Schedule notifications on app launch
                    await NotificationManager.shared.scheduleNotifications()
                    
                    // Start Om chant if enabled
                    if omChantEnabled {
                        AudioManager.shared.setVolume(Float(omChantVolume))
                        AudioManager.shared.playOmChant()
                    }
                }
        }
    }
}

// App Delegate to handle audio interruptions
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Register for audio interruption notifications
        NotificationCenter.default.addObserver(
            AudioManager.shared,
            selector: #selector(AudioManager.shared.handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        return true
    }
}
