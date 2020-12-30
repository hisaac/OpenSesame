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
		return true
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		for url in urls {
			handleURL(url: url)
		}
	}

	func handleURL(url: URL) {
		guard let host = url.host else {
			fallbackToDefaultBrowser(url: url)
			return
		}

		// Expand known shortlinks
		// swiftlint:disable statement_position
		if host.contains("t.co") || host.contains("bit.ly") {
			expandURL(url: url)
		}

		else if host.contains("music.apple.com") {
			handleAppleMusicURL(url: url)
		}

		else if host.contains("open.spotify.com") {
			handleSpotifyURL(url: url)
		}

		else if host.contains("zoom.us") && url.pathComponents.doesNotContain("saml") {
			handleZoomURL(url: url)
		}

		else {
			fallbackToDefaultBrowser(url: url)
		}
		// swiftlint:enable statement_position
	}

	func fallbackToDefaultBrowser(url: URL) {
		guard let safariURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari") else { return }
		openURLFollowingActivation(url: url, withApplicationAt: safariURL)
	}

	func expandURL(url: URL) {
		url.resolveWithCompletionHandler { [weak self] in
			self?.handleURL(url: $0)
		}
	}

	func handleAppleMusicURL(url: URL) {
		guard let appleMusicAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Music") else {
			return
		}

		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "itms"
		guard let urlToOpen = urlComponents?.url else { return }

		openURLFollowingActivation(url: urlToOpen, withApplicationAt: appleMusicAppURL)
	}

	func handleSpotifyURL(url: URL) {
		guard let spotifyAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.spotify.client") else {
			return
		}

		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "spotify"

		let host = url.pathComponents[1]
		urlComponents?.host = host

		let path = "/" + url.pathComponents.dropFirst(2).joined(separator: "/")
		urlComponents?.path = path

		guard let urlToOpen = urlComponents?.url else { return }

		openURLFollowingActivation(url: urlToOpen, withApplicationAt: spotifyAppURL)
	}

	func handleZoomURL(url: URL) {
		guard let zoomAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "us.zoom.xos") else { return }

		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "zoommtg"

		if urlComponents?.path.contains("/j/") == true {
			urlComponents?.path = "/join"

			let conferenceNumberQueryItem = URLQueryItem(name: "confno", value: url.pathComponents.last)
			urlComponents?.queryItems?.append(conferenceNumberQueryItem)
		}

		guard let urlToOpen = urlComponents?.url else { return }

		openURLFollowingActivation(url: urlToOpen, withApplicationAt: zoomAppURL)
	}

	func openURLFollowingActivation(url: URL, withApplicationAt applicationURL: URL) {
		let openConfiguration = NSWorkspace.OpenConfiguration()
		openConfiguration.activates = NSApp.isActive
		NSWorkspace.shared.open(
			[url],
			withApplicationAt: applicationURL,
			configuration: openConfiguration,
			completionHandler: nil
		)
	}

}

extension URL {
	func resolveWithCompletionHandler(completion: @escaping (URL) -> Void) {
		let originalURL = self
		var req = URLRequest(url: originalURL)
		req.httpMethod = "HEAD"

		URLSession.shared.dataTask(with: req) { body, response, error in
			completion(response?.url ?? originalURL)
		}.resume()
	}
}

extension Array where Self.Element: Equatable {
	func doesNotContain(_ element: Element) -> Bool {
		return self.contains(element).toggled
	}
}

extension Bool {
	var toggled: Bool {
		var mutableSelf = self
		mutableSelf.toggle()
		return mutableSelf
	}
}
