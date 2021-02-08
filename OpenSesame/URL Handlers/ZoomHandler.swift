//
//  ZoomHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import Foundation

final class ZoomHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	func canHandle(_ url: URL) -> Bool {
		guard Settings.handleZoomURLs,
			  let host = url.host else {
			return false
		}

		let isZoomMeetingURL = host.hasSuffix("zoom.us") &&
			url.pathComponents.containsNone(of: "saml", "oauth")

		return isZoomMeetingURL
	}

	func handle(_ url: URL) {
		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "zoommtg"

		if urlComponents?.path.contains("/j/") == true {
			urlComponents?.path = "/join"

			let conferenceNumberQueryItem = URLQueryItem(name: "confno", value: url.pathComponents.last)
			urlComponents?.queryItems?.append(conferenceNumberQueryItem)
		}

		delegate?.open(
			urlComponents: urlComponents,
			from: url,
			usingApplicationWithBundleIdentifier: URLOpener.KnownBundleIdentifier.zoom.rawValue
		)
	}

}
