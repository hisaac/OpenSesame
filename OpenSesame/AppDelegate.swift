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

	func applicationDidFinishLaunching(_ notification: Notification) {
		let handlers = URLHandler.getHTMLHandlers()
		print(handlers)
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return false
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		URLHandler.handle(urls)
	}

}
