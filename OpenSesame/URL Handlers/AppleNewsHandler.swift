//
//  AppleNewsHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import Foundation

final class AppleNewsHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	func canHandle(_ url: URL) -> Bool {
		guard Settings.handleAppleNewsURLs,
			  let host = url.host else {
			return false
		}

		let isAppleNewsURL = host.endsWithAny(of: "news.apple.com", "apple.news")

		return isAppleNewsURL
	}

	func handle(_ url: URL) {
		// TODO: Handle Apple News URLs (by opening them in the browser instead)
		// Will need to set this app has default handler for applenews schemes
		// applenews:// and applenewss://
		delegate?.open(url, usingFallbackHandler: true)
	}

}
