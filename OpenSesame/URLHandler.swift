//
//  URLHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 12/29/20.
//

import AppKit
import LSFoundation

enum KnownBundleIdentifier: String {
	case appStore = "com.apple.AppStore"
	case music = "com.apple.Music"
	case news = "com.apple.news"
	case tweetbot = "com.tapbots.Tweetbot3Mac"
	case twitter = "maccatalyst.com.atebits.Tweetie2"
	case spotify = "com.spotify.client"
	case zoom = "us.zoom.xos"

	// Browsers
	case safari = "com.apple.Safari"
	case firefox = "org.mozilla.firefox"
	case chrome = "com.google.Chrome"
	case opera = "com.operasoftware.Opera"
}

class URLHandler {

	private let workspace = NSWorkspace.shared

	private let knownShortLinkHosts = [
		"adf.ly",
		"bit.do",
		"bit.ly",
		"buff.ly",
		"deck.ly",
		"fur.ly",
		"goo.gl",
		"is.gd",
		"mcaf.ee",
		"ow.ly",
		"spoti.fi",
		"su.pr",
		"t.co",
		"tiny.cc",
		"tinyurl.com"
	]

	func handle(_ urls: [URL]) {
		for url in urls {
			handle(url)
		}
	}

	func handle(_ url: URL) {
		guard Settings.urlHandlingEnabled,
			  let host = url.host else {
			openWithDefaultFallbackBrowser(url)
			return
		}

		// swiftlint:disable statement_position
		if host.endsWithAny(of: knownShortLinkHosts),
		   Settings.handleShortLinkURLs {
			expandURL(url)
		}

		else if host.hasSuffix("apps.apple.com") ||
					(host.hasSuffix("itunes.apple.com") && url.pathComponents.contains("app")) {
			if Settings.handleAppStoreURLs {
				handleAppStoreURL(url)
			}
		}

		else if host.hasSuffix("music.apple.com") ||
					(host.hasSuffix("itunes.apple.com") && url.pathComponents.doesNotContain("app")) {
			if Settings.handleAppleMusicURLs {
				handleAppleMusicURL(url)
			}
		}

		else if host.hasSuffix("open.spotify.com") {
			handleSpotifyURL(url)
		}

		else if host.hasSuffix("zoom.us"),
				url.pathComponents.containsNone(of: "saml", "oauth") {
			handleZoomURL(url)
		}

		else if host.hasSuffix("twitter.com") {
			handleTwitterURL(url)
		}

		else if host.endsWithAny(of: "news.apple.com", "apple.news") {
			// TODO: Handle Apple News URLs (by opening them in the browser instead)
			// Will need to set this app has default handler for applenews schemes
			// applenews:// and applenewss://
			openWithDefaultFallbackBrowser(url)
		}

		else {
			openWithDefaultFallbackBrowser(url)
		}
		// swiftlint:enable statement_position
	}

	// swiftlint:disable line_length
	private func openWithDefaultFallbackBrowser(_ url: URL) {
		var fallbackAppURL: URL
		if let defaultFallbackAppURL = workspace.urlForApplication(withBundleIdentifier: Settings.defaultFallbackBrowserBundleIdentifier) {
			fallbackAppURL = defaultFallbackAppURL
		} else if let safariAppURL = workspace.urlForApplication(withBundleIdentifier: KnownBundleIdentifier.safari.rawValue) {
			fallbackAppURL = safariAppURL
		} else {
			// TODO: Implement real error handling/logging
			print("ERROR")
			return
		}

		open(url: url, usingApplicationAt: fallbackAppURL)
	}
	// swiftlint:enable line_length

	private func expandURL(_ url: URL) {
		url.resolveWithCompletionHandler { [weak self] in
			self?.handle($0)
		}
	}

	private func handleAppStoreURL(_ url: URL) {
		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "macappstore"
		open(
			urlComponents: urlComponents,
			from: url,
			usingApplicationWithBundleIdentifier: KnownBundleIdentifier.appStore.rawValue
		)
	}

	private func handleAppleMusicURL(_ url: URL) {
		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "itms"
		open(
			urlComponents: urlComponents,
			from: url,
			usingApplicationWithBundleIdentifier: KnownBundleIdentifier.music.rawValue
		)
	}

	private func handleSpotifyURL(_ url: URL) {
		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "spotify"

		let host = url.pathComponents[1]
		urlComponents?.host = host

		let path = "/" + url.pathComponents.dropFirst(2).joined(separator: "/")
		urlComponents?.path = path

		open(
			urlComponents: urlComponents,
			from: url,
			usingApplicationWithBundleIdentifier: KnownBundleIdentifier.spotify.rawValue
		)
	}

	private func handleZoomURL(_ url: URL) {
		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "zoommtg"

		if urlComponents?.path.contains("/j/") == true {
			urlComponents?.path = "/join"

			let conferenceNumberQueryItem = URLQueryItem(name: "confno", value: url.pathComponents.last)
			urlComponents?.queryItems?.append(conferenceNumberQueryItem)
		}

		open(
			urlComponents: urlComponents,
			from: url,
			usingApplicationWithBundleIdentifier: KnownBundleIdentifier.zoom.rawValue
		)
	}


	/// If Twitter tries to open the URL of a tweet that doesn't exist (if it were deleted for instance), it sends the URL instead to the default browser
	/// which in thise case is our app. This causes an undending loop. So here we track if the current Twitter URL is the same one that was just tried to open,
	/// and send it to the default browser if so.
	private var lastURLHandledByTwitter: URL?

	private func handleTwitterURL(_ url: URL) {
		guard url != lastURLHandledByTwitter else {
			openWithDefaultFallbackBrowser(url)
			return
		}

		lastURLHandledByTwitter = url
		open(
			url: url,
			usingApplicationWithBundleIdentifier: KnownBundleIdentifier.twitter.rawValue
		)
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
			openWithDefaultFallbackBrowser(url)
		}

		open(
			urlComponents: urlComponents,
			from: url,
			usingApplicationWithBundleIdentifier: KnownBundleIdentifier.tweetbot.rawValue
		)
	}

	private func open(urlComponents: URLComponents?,
					  from originalURL: URL,
					  usingApplicationWithBundleIdentifier bundleIdentifier: String) {
		guard let urlFromComponents = urlComponents?.url else {
			// TODO: Implement real logging
			print("Unable to generate URL from URLComponents. Opening original URL in default browser instead.")
			openWithDefaultFallbackBrowser(originalURL)
			return
		}

		open(url: urlFromComponents, usingApplicationWithBundleIdentifier: bundleIdentifier)
	}

	private func open(url: URL, usingApplicationWithBundleIdentifier bundleIdentifier: String) {
		guard let applicationURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
			openWithDefaultFallbackBrowser(url)
			return
		}
		open(url: url, usingApplicationAt: applicationURL)
	}

	private func open(url: URL, usingApplicationAt applicationURL: URL) {
		// Checking `NSApp.isActive` must be done on the main thread
		DispatchQueue.main.async { [weak self] in
			let openConfiguration = NSWorkspace.OpenConfiguration()
			openConfiguration.activates = NSApp.isActive

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
