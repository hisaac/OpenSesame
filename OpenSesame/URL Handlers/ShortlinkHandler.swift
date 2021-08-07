//
//  ShortlinkHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import Defaults
import Foundation

final class ShortlinkHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	// TODO: Give users the ability to customize shortlink domains
	let knownShortLinkDomains = [
		"adf.ly",
		"bit.do",
		"bit.ly",
		"buff.ly",
		"deck.ly",
		"fur.ly",
		"goo.gl",
		"is.gd",
		"list-manage.com",
		"mcaf.ee",
		"ow.ly",
		"spoti.fi",
		"su.pr",
		"t.co",
		"tiny.cc",
		"tinyurl.com"
	]

	func canHandle(_ url: URL) -> Bool {
		guard Defaults[.handleShortLinkURLs],
			  let host = url.host else {
			return false
		}

		return knownShortLinkDomains.contains(where: { $0.hasSuffix(host) })
	}

	func handle(_ url: URL) {
		// TODO: Add a transparent spinner window to show that the shortlink URL is being expanded
		// It can sometimes take a couple seconds, and I don't want people to think nothing is happening
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
