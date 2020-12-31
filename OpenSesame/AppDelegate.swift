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
		let handlers = getHTMLHandlers()
		print(handlers)
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return false
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		URLHandler.handle(urls)
	}

	func getHTMLHandlers() -> [Bundle] {
		let htmlUTI = "public.html" as CFString

		guard let htmlViewersCFArray = LSCopyAllRoleHandlersForContentType(htmlUTI, .viewer),
			  let htmlViewers = htmlViewersCFArray.takeRetainedValue() as? [String] else {
			return []
		}

		var viewerBundles: [Bundle] = []
		for viewer in htmlViewers {
			guard let viewerURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: viewer),
				  let viewerBundle = Bundle(url: viewerURL),
				  let urlTypes = viewerBundle.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: AnyObject]] else {
				continue
			}
			let urlSchemes = urlTypes.compactMap { $0["CFBundleURLSchemes"] as? [String] }
			if urlSchemes.contains(where: { $0.contains("http") }) {
                viewerBundles.append(viewerBundle)
			}
		}

		return viewerBundles
	}

}
