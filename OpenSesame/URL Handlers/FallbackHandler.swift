//
//  FallbackHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import Defaults
import Foundation

final class FallbackHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	func canHandle(_ url: URL) -> Bool {
		// always returns true, because this is the fallback
		return true
	}

	// swiftlint:disable line_length
	func handle(_ url: URL) {
		var fallbackAppURL: URL
		if let defaultFallbackAppURL = delegate?.workspace.urlForApplication(withBundleIdentifier: Defaults[.defaultFallbackBrowserBundleIdentifier]) {
			fallbackAppURL = defaultFallbackAppURL
		} else if let safariAppURL = delegate?.workspace.urlForApplication(withBundleIdentifier: URLOpener.KnownBundleIdentifier.safari.rawValue) {
			fallbackAppURL = safariAppURL
		} else {
			// TODO: Implement real error handling/logging
			print("ERROR")
			return
		}

		delegate?.open(url: url, usingApplicationAt: fallbackAppURL)
	}
	// swiftlint:enable line_length
}
