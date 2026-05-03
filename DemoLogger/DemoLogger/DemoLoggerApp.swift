//
//  DemoLoggerApp.swift
//  DemoLogger
//
//  Created by Kiên Vũ on 7/11/24.
//

import SwiftUI
import Logger

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        Log.`init`(
            identifier: Bundle.main.bundleIdentifier ?? "", appVersion: appVersion ?? "", supportRecord: true, logFileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("logs")
        )

        return true
    }
}


@main
struct DemoLoggerApp: App {
    
    @UIApplicationDelegateAdaptor
    var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
