// MineswapperApp.swift
// Mineswapper - App entry point

import SwiftUI

@main
struct MineswapperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1100, height: 700)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Activate the app and bring to front
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        // Set app appearance
        NSApp.appearance = NSAppearance(named: .aqua)
    }
}
