//
//  AppleMusicHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import Defaults
import Foundation

final class AppleMusicHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	func canHandle(_ url: URL) -> Bool {
		guard Defaults[.handleAppleMusicURLs],
			  let host = url.host else {
			return false
		}

		let isAppleMusicURL = host.hasSuffix("music.apple.com") ||
			(host.hasSuffix("itunes.apple.com") && url.pathComponents.doesNotContain("app"))

		return isAppleMusicURL
	}

	func handle(_ url: URL) {
		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "itms"
		delegate?.open(
			urlComponents: urlComponents,
			from: url,
			usingApplicationWithBundleIdentifier: URLOpener.KnownBundleIdentifier.music.rawValue
		)
	}

}
