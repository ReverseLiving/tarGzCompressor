//
//  tarGzCompressorApp.swift
//  tarGzCompressor
//
//  Created by n1a9o92egtd on 2022/8/11.
//

//  https://opensource.apple.com/source/

import SwiftUI
import AppKit

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, ObservableObject {
    open dynamic var is_close:Bool = true
    open dynamic var w:CGFloat = 800.0
    open dynamic var h:CGFloat = 500.0
    func applicationWillFinishLaunching(_ aNotification: Notification) {
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainWindow = NSApp.windows[0]
        let screen = NSScreen.screens[0]
        self.w = screen.frame.width / 2
        self.h = screen.frame.height / 2
        mainWindow.setContentSize(NSSize(width: screen.frame.width / 2, height: screen.frame.height / 2))
        mainWindow.styleMask = [.closable, .miniaturizable, .borderless, .titled]
        mainWindow.backingType = .buffered
        mainWindow.backgroundColor = NSColor(Color.purple)
        mainWindow.delegate = self
        mainWindow.center()
        mainWindow.setFrameOrigin(CGPoint(x: mainWindow.frame.origin.x, y: mainWindow.frame.origin.y))
        mainWindow.titlebarSeparatorStyle = NSTitlebarSeparatorStyle.shadow
        mainWindow.titlebarAppearsTransparent = true
        self.is_close = true
    }
    func applicationWillTerminate(_ aNotification: Notification) {
    }
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if self.is_close {
            NSApp.terminate(self)
            return true
        }
        else {
            NSApp.hide(nil)
            return false
        }
    }
}
#endif

@main
struct tarGzCompressorApp: App {
#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    var body: some Scene {
        WindowGroup {
            tarGzCompressorView().frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.purple)
        }
    }
}
