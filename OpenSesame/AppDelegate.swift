//
//  AppDelegate.swift
//  OpenSesame
//
//  Created by Isaac Halvorson on 11/30/20.
//

import Cocoa
import LSFoundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet var window: NSWindow!
	let urlHandler = URLHandler()

	func applicationDidFinishLaunching(_ notification: Notification) {
		#warning("Temporary hack for now to make app less annoying")
		NSApp.hide(self)

		// To be used when implementing default browser choice
//		let handlers = urlHandler.getHTMLHandlers()
//		print(handlers)
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return false
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		urlHandler.handle(urls)
	}

}
