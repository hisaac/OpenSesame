//
//  DiscordHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 3/27/21.
//

import Foundation

final class DiscordHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	func canHandle(_ url: URL) -> Bool {
		guard Settings.handleDiscordURLs else {
			return false
		}

		// TODO: Find way to determine if this is a Discord URL
		let isDiscordURL = false

		return isDiscordURL
	}

	func handle(_ url: URL) {
		// TODO: Figure out modification of URL necessary
		delegate?.open(url, usingFallbackHandler: true)
	}
}
