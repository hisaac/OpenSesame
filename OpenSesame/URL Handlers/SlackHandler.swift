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
		guard Settings.handleSlackURLs else {
			return false
		}

		// TODO: Find way to determine if this is a Slack URL
		let isSlackURL = false

		return isSlackURL
	}

	// TODO: Determine if this is needed or not
	private var lastURLHandledBySlack: URL?

	func handle(_ url: URL) {
		guard url != lastURLHandledBySlack else {
			delegate?.open(url, usingFallbackHandler: true)
			return
		}

		lastURLHandledBySlack = url

		// TODO: Figure out modification of URL necessary (slack://) https://api.slack.com/reference/deep-linking
		delegate?.open(url, usingFallbackHandler: true)
	}
}
