//
//  ZoomHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import Defaults
import Foundation

final class ZoomHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	func canHandle(_ url: URL) -> Bool {
		guard Defaults[.handleZoomURLs],
			  let host = url.host else {
			return false
		}

		let isZoomMeetingURL = host.hasSuffix("zoom.us") &&
			url.pathComponents.containsNone(of: "saml", "oauth", "share")

		return isZoomMeetingURL
	}

	func handle(_ url: URL) {
		if let zoomURL = ZoomMeetingURL(url)?.url {
			delegate?.open(url: zoomURL, usingApplicationWithBundleIdentifier: KnownBundleIdentifier.zoom.rawValue)
		} else {
			delegate?.open(url, usingFallbackHandler: true)
		}
	}
}

struct ZoomMeetingURL {

	// TODO: Add more url parameters from here: https://marketplace.zoomgov.com/docs/guides/guides/client-url-schemes

	private let scheme = "zoommtg"
	let host: String
	let action: Action
	let conferenceNumber: Int
	let password: String?

	init?(_ url: URL) {
		guard let host = url.host,
			  host.hasSuffix("zoom.us"),
			  url.pathComponents.containsNone(of: "saml", "oauth", "share") else {
			return nil
		}
		self.host = host

		guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			return nil
		}

		guard let action = Action(path: urlComponents.path) else { return nil }
		self.action = action

		if let conferenceNumberQueryItem = urlComponents.queryItems?.first(where: { $0.name == "confno" }),
		   let conferenceNumberQueryItemValue = conferenceNumberQueryItem.value,
		   let conferenceNumber = Int(conferenceNumberQueryItemValue) {
			self.conferenceNumber = conferenceNumber
		} else if let actionIndex = (url.pathComponents.firstIndex(of: "j") ?? url.pathComponents.firstIndex(of: "p")),
				  actionIndex < url.pathComponents.count - 1,
				  let conferenceNumber = Int(url.pathComponents[actionIndex + 1]) {
			self.conferenceNumber = conferenceNumber
		} else {
			return nil
		}

		let passwordQueryItem = urlComponents.queryItems?.first(where: { $0.name == "pwd" })
		password = passwordQueryItem?.value
	}

	var url: URL? {
		var urlComponents = URLComponents()
		urlComponents.scheme = scheme
		urlComponents.host = host
		urlComponents.path = action.path

		if urlComponents.queryItems == nil { urlComponents.queryItems = [] }
		urlComponents.queryItems?.append(
			URLQueryItem(name: "confno", value: String(conferenceNumber))
		)

		if let password = password {
			urlComponents.queryItems?.append(
				URLQueryItem(name: "pwd", value: password)
			)
		}

		return urlComponents.url
	}

	enum Action: String {
		case join
		case start

		init?(path: String) {
			if path.containsAny(of: "/j/", "join?") {
				self = .join
			} else if path.containsAny(of: "/s/", "start?") {
				self = .start
			} else {
				return nil
			}
		}

		var path: String {
			return "/\(rawValue)"
		}
	}
}
