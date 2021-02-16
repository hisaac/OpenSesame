//
//  ShortlinkHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import Foundation

final class ShortlinkHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	let knownShortLinkHosts = [
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

	func canHandle(_ url: URL) -> Bool {
		guard Settings.handleShortLinkURLs,
			  let host = url.host else {
			return false
		}

		return knownShortLinkHosts.contains(host)
	}

	func handle(_ url: URL) {
		url.resolveWithCompletionHandler { [weak self] in
			self?.delegate?.open($0)
		}
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
