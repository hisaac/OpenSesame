//
//  AppDelegate.swift
//  OpenSesame
//
//  Created by Isaac Halvorson on 11/30/20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ notification: Notification) {

	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return false
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		URLHandler.handle(urls)
	}

}
