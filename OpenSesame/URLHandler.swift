//
//  URLHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 12/29/20.
//

import AppKit
import LSFoundation

class URLHandler {

	private var lastURLHandled: URL?
	private let workspace = NSWorkspace.shared

	private enum HandledBundleIdentifier: String {
		case music = "com.apple.Music"
		case tweetbot = "com.tapbots.Tweetbot3Mac"
		case twitter = "maccatalyst.com.atebits.Tweetie2"
		case spotify = "com.spotify.client"
		case zoom = "us.zoom.xos"

		// Implement ability to add arbitrary default browser case
		case `default` = "com.apple.Safari"
	}

	func handle(_ urls: [URL]) {
		for url in urls {
			handle(url)
		}
	}

	#warning("TODO: Handle Mac App Store URLs")
	#warning("TODO: Handle Apple News URLs (by opening them in the browser instead")

	func handle(_ url: URL) {
		guard url != lastURLHandled,
			  let host = url.host else {
			openWithDefaultBrowser(url)
			return
		}

		lastURLHandled = url

		// swiftlint:disable statement_position
		if host.containsAny(of: "t.co", "bit.ly") {
			expandURL(url)
		}

		else if host.containsAny(of: "music.apple.com", "itunes.apple.com") {
			handleAppleMusicURL(url)
		}

		else if host.contains("open.spotify.com") {
			handleSpotifyURL(url)
		}

		else if host.contains("zoom.us"),
				url.pathComponents.containsNone(of: "saml", "oauth") {
			handleZoomURL(url)
		}

		else if host.contains("twitter.com") {
			handleTwitterURL(url)
		}

		else {
			openWithDefaultBrowser(url)
		}
		// swiftlint:enable statement_position
	}

	private func openWithDefaultBrowser(_ url: URL) {
		open(url: url, usingApplicationWithBundleIdentifier: .default)
	}

	private func expandURL(_ url: URL) {
		url.resolveWithCompletionHandler { [weak self] in
			self?.handle($0)
		}
	}

	private func handleAppleMusicURL(_ url: URL) {
		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "itms"
		open(urlComponents: urlComponents, from: url, usingApplicationWithBundleIdentifier: .music)
	}

	private func handleSpotifyURL(_ url: URL) {
		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "spotify"

		let host = url.pathComponents[1]
		urlComponents?.host = host

		let path = "/" + url.pathComponents.dropFirst(2).joined(separator: "/")
		urlComponents?.path = path

		open(urlComponents: urlComponents, from: url, usingApplicationWithBundleIdentifier: .spotify)
	}

	private func handleZoomURL(_ url: URL) {
		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "zoommtg"

		if urlComponents?.path.contains("/j/") == true {
			urlComponents?.path = "/join"

			let conferenceNumberQueryItem = URLQueryItem(name: "confno", value: url.pathComponents.last)
			urlComponents?.queryItems?.append(conferenceNumberQueryItem)
		}

		open(urlComponents: urlComponents, from: url, usingApplicationWithBundleIdentifier: .zoom)
	}

	private func handleTwitterURL(_ url: URL) {
		open(url: url, usingApplicationWithBundleIdentifier: .twitter)
	}

	/// This currently works for opening individual posts, but nothing else yet
	@available(*, unavailable, message: "Tweetbot handler not yet finished")
	private func handleTwitterURLUsingTweetbot(_ url: URL) {
		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "tweetbot"
		urlComponents?.queryItems = nil

		if let path = urlComponents?.path,
		   path.contains("status") {
			let pathComponents = path.split(separator: "/")
			let user = String(pathComponents.first ?? "")
			let tweetID = String(pathComponents.last ?? "")
			urlComponents?.host = user
			urlComponents?.path = "/status/\(tweetID)"
		} else {
			openWithDefaultBrowser(url)
		}

		open(urlComponents: urlComponents, from: url, usingApplicationWithBundleIdentifier: .tweetbot)
	}

	private func open(urlComponents: URLComponents?,
					  from originalURL: URL,
					  usingApplicationWithBundleIdentifier bundleIdentifier: HandledBundleIdentifier) {
		guard let urlFromComponents = urlComponents?.url else {
			#warning("TODO: Implement real logging")
			print("Unable to generate URL from URLComponents. Opening original URL in default browser instead.")
			openWithDefaultBrowser(originalURL)
			return
		}

		open(url: urlFromComponents, usingApplicationWithBundleIdentifier: bundleIdentifier)
	}

	private func open(url: URL, usingApplicationWithBundleIdentifier bundleIdentifier: HandledBundleIdentifier) {
		guard let applicationURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier.rawValue) else {
			openWithDefaultBrowser(url)
			return
		}
		open(url: url, usingApplicationAt: applicationURL)
	}

	private func open(url: URL, usingApplicationAt applicationURL: URL) {
		// Checking `NSApp.isActive` must be done on the main thread
		DispatchQueue.main.async { [weak self] in
			let openConfiguration = NSWorkspace.OpenConfiguration()
			openConfiguration.activates = NSApp.isActive

			#warning("Temporary hack for now to make app less annoying")
			if NSApp.isActive {
				NSApp.hide(self)
			}

			self?.workspace.open(
				[url],
				withApplicationAt: applicationURL,
				configuration: openConfiguration,
				completionHandler: nil
			)
		}
	}

	func getHTMLHandlers() -> [Bundle] {
		let htmlUTI = "public.html" as CFString

		guard let htmlViewersCFArray = LSCopyAllRoleHandlersForContentType(htmlUTI, .viewer),
			  let htmlViewers = htmlViewersCFArray.takeRetainedValue() as? [String] else {
			return []
		}

		var viewerBundles: [Bundle] = []
		for viewer in htmlViewers {
			guard let viewerURL = workspace.urlForApplication(withBundleIdentifier: viewer),
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

		let urlSession = URLSession(configuration: .ephemeral)
		let dataTask = urlSession.dataTask(with: req) { body, response, error in
			completion(response?.url ?? originalURL)
		}
		dataTask.priority = 1.0
		dataTask.resume()
	}
}
