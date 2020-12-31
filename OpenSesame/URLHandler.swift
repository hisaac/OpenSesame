//
//  URLHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 12/29/20.
//

import AppKit

enum URLHandler {

	static func handle(_ urls: [URL]) {
		for url in urls {
			handle(url)
		}
	}

	static func handle(_ url: URL) {
		guard let host = url.host else {
			fallbackToDefaultBrowser(url: url)
			return
		}

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

	private static func fallbackToDefaultBrowser(url: URL) {
		guard let safariURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari") else { return }
		openURLPassingAppActivation(url: url, withApplicationAt: safariURL)
	}

	private static func expandURL(url: URL) {
		url.resolveWithCompletionHandler {
			URLHandler.handle($0)
		}
	}

	private static func handleAppleMusicURL(url: URL) {
		guard let appleMusicAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Music") else {
			return
		}

		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "itms"
		guard let urlToOpen = urlComponents?.url else { return }

		openURLPassingAppActivation(url: urlToOpen, withApplicationAt: appleMusicAppURL)
	}

	private static func handleSpotifyURL(url: URL) {
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

		openURLPassingAppActivation(url: urlToOpen, withApplicationAt: spotifyAppURL)
	}

	private static func handleZoomURL(url: URL) {
		guard let zoomAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "us.zoom.xos") else { return }

		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "zoommtg"

		if urlComponents?.path.contains("/j/") == true {
			urlComponents?.path = "/join"

			let conferenceNumberQueryItem = URLQueryItem(name: "confno", value: url.pathComponents.last)
			urlComponents?.queryItems?.append(conferenceNumberQueryItem)
		}

		guard let urlToOpen = urlComponents?.url else { return }

		openURLPassingAppActivation(url: urlToOpen, withApplicationAt: zoomAppURL)
	}

	private static func openURLPassingAppActivation(url: URL, withApplicationAt applicationURL: URL) {
		let openConfiguration = NSWorkspace.OpenConfiguration()
		openConfiguration.activates = NSApp.isActive
		NSWorkspace.shared.open(
			[url],
			withApplicationAt: applicationURL,
			configuration: openConfiguration,
			completionHandler: nil
		)
	}

	static func getHTMLHandlers() -> [Bundle] {
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
