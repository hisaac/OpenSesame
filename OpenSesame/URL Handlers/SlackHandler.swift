//
//  SlackHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import Foundation

final class SlackHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	func canHandle(_ url: URL) -> Bool {
		guard Settings.handleSlackURLs,
			  let host = url.host else {
			return false
		}

		let isSlackURL = host.hasSuffix("slack.com")

		// TODO: Actually figure this out
		return false
	}

	func handle(_ url: URL) {
		// TODO: Figure out modification of URL necessary (slack://) https://api.slack.com/reference/deep-linking
		delegate?.open(url: url, usingApplicationWithBundleIdentifier: URLOpener.KnownBundleIdentifier.slack.rawValue)
	}
}
