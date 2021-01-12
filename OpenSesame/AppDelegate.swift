//
//  AppDelegate.swift
//  OpenSesame
//
//  Created by Isaac Halvorson on 11/30/20.
//

import AppKit
import LSFoundation
import os.log
import Preferences

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet var window: NSWindow!
	let urlOpener = URLOpener()
	var statusItemController: StatusItemController?

	// TODO: Create custom logger class that uses `Logger` or `OSLog` depending on the operating system
	// https://developer.apple.com/documentation/os/logging/generating_log_messages_from_your_code
	// https://nshipster.com/swift-log/
	let logger: OSLog = {
		let subsystem = Bundle.main.bundleIdentifier ?? ""
		let category = #file
		return OSLog(subsystem: subsystem, category: category)
	}()

	lazy var preferencesWindowController = PreferencesWindowController(
		preferencePanes: [GeneralPreferenceViewController()],
		hidesToolbarForSingleItem: true
	)

	func applicationDidFinishLaunching(_ notification: Notification) {
		statusItemController = StatusItemController(logger: logger)
		statusItemController?.delegate = self
		statusItemController?.enable()

		print("Current default browser:", OSLaunchServices.defaultHTMLViewerApp ?? "Unknown")

		if Settings.firstLaunch {
			openPreferencesWindow()
			Settings.firstLaunch = false
		}

		#if DEBUG
		openPreferencesWindow()
		Settings.debugEnabled = true
		#endif
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return false
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		urlOpener.open(urls)
	}

}

extension AppDelegate: Enablable {
	private(set) var isEnabled: Bool {
		get { Settings.urlHandlingEnabled }
		set {
			Settings.urlHandlingEnabled = newValue
			if newValue {
				enable()
			} else {
				disable()
			}
		}
	}

	func enable() {

	}

	func disable() {

	}

}

extension AppDelegate: PreferencesWindowDelegate {
	func openPreferencesWindow() {
		NSApp.activate(ignoringOtherApps: true)
		preferencesWindowController.show()
	}
}
