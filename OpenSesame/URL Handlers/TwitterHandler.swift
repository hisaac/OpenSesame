//
//  TwitterHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import Foundation

final class TwitterHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	func canHandle(_ url: URL) -> Bool {
		guard Settings.handleTwitterURLs,
			  let host = url.host else {
			return false
		}

		let isTwitterURL = host.hasSuffix("twitter.com")

		return isTwitterURL
	}

	func handle(_ url: URL) {
		handleUsingTwitterApp(url)
	}

	/// If Twitter tries to open the URL of a tweet that doesn't exist (if it were deleted for instance), it sends the URL instead to the default browser
	/// — which is Open Sesame — so this causes an infinite loop.
	private var lastURLHandledByTwitterApp: URL?
	private var timeOfLastURLHandledByTwitterApp = Date.distantPast

	private func handleUsingTwitterApp(_ url: URL) {

		// If the URL we're trying to open is the same as the last one,
		// and it has been less than 1 second since we last opened the URL,
		// then send the link to the fallback browser to avoid an infinite loop (mentioned above)
		if url == lastURLHandledByTwitterApp,
		   timeOfLastURLHandledByTwitterApp.timeIntervalSinceNow <= 1 {
			delegate?.open(url, usingFallbackHandler: true)
			return
		}

		lastURLHandledByTwitterApp = url

		if #available(macOS 12, *) {
			timeOfLastURLHandledByTwitterApp = .now
		} else {
			timeOfLastURLHandledByTwitterApp = Date()
		}

		delegate?.open(url: url, usingApplicationWithBundleIdentifier: URLOpener.KnownBundleIdentifier.twitter.rawValue)
	}

	/// This currently works for opening individual posts, but nothing else yet
	@available(*, unavailable, message: "Tweetbot handler not yet finished")
	private func handleUsingTweetbot(_ url: URL) {
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
			delegate?.open(url, usingFallbackHandler: true)
		}

		delegate?.open(
			urlComponents: urlComponents,
			from: url,
			usingApplicationWithBundleIdentifier: URLOpener.KnownBundleIdentifier.tweetbot.rawValue
		)
	}

}
