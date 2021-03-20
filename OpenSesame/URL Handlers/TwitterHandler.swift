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
	/// which in this case is our app. This causes an unending loop. So here we track if the current Twitter URL is the same one that was just tried to open,
	/// and send it to the default browser if so.
	private var lastURLHandledByTwitterApp: URL?

	private func handleUsingTwitterApp(_ url: URL) {
		guard url != lastURLHandledByTwitterApp else {
			delegate?.open(url, usingFallbackHandler: true)
			return
		}

		lastURLHandledByTwitterApp = url
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
