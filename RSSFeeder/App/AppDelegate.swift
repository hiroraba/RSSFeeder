//
//  AppDelegate.swift
//
//
//  Created by matsuohiroki on 2025/04/24.
//
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let rootViewController = MainSplitViewController(nibName: nil, bundle: nil)

        let window = NSWindow(
            contentRect: NSMakeRect(100, 100, 800, 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = rootViewController
        window.makeKeyAndOrderFront(nil)
        print("🔥 AppDelegate fired")
        self.window = window
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
