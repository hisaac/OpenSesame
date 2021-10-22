//
//  AppDelegate.swift
//  OpenSesame
//
//  Created by Isaac Halvorson on 11/30/20.
//

import AppKit
import Defaults
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
		panes: [
			Preferences.Pane(
				identifier: .general,
				title: "General",
				toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "General Preferences")!,
				contentView: { GeneralPreferencesView() }
			),
			Preferences.Pane(
				identifier: .urlHandlers,
				title: "URL Handlers",
				toolbarIcon: NSImage(systemSymbolName: "link", accessibilityDescription: "URL Handler Preferences")!,
				contentView: { URLHandlerPreferencesView() }
			)
		]
	)

	func applicationDidFinishLaunching(_ notification: Notification) {
		statusItemController = StatusItemController(logger: logger)
		statusItemController?.delegate = self

		fixPreferencesWindowOddAnimation()

		print("Current default browser:", OSLaunchServices.defaultHTMLViewerApp ?? "Unknown")

		if Defaults[.firstLaunch] {
			Defaults[.firstLaunch] = false
			openPreferencesWindow()
		}

//		#if DEBUG
//		openPreferencesWindow()
//		Settings.debugEnabled = true
//		#endif
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return false
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		urlOpener.open(urls)
	}

	/// Workaround for a strange issue where the animation for the preferences window does not work correctly
	/// source: https://github.com/sindresorhus/Preferences/issues/60#issuecomment-886146196
	func fixPreferencesWindowOddAnimation() {
		preferencesWindowController.show(preferencePane: .urlHandlers)
		preferencesWindowController.show(preferencePane: .general)
		preferencesWindowController.close()
	}
}

protocol PreferencesWindowDelegate: AnyObject {
	func openPreferencesWindow()
}

extension AppDelegate: PreferencesWindowDelegate {
	func openPreferencesWindow() {
		preferencesWindowController.show()
	}
}
