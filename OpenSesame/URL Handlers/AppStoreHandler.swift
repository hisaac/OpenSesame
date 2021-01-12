//
//  AppStoreHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import Foundation

final class AppStoreHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	func canHandle(_ url: URL) -> Bool {
		guard Settings.handleAppStoreURLs,
			  let host = url.host else {
			return false
		}

		let isAppStoreURL = host.hasSuffix("apps.apple.com") ||
			(host.hasSuffix("itunes.apple.com") && url.pathComponents.contains("app"))

		return isAppStoreURL
	}

	func handle(_ url: URL) {
		var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		urlComponents?.scheme = "macappstore"
		delegate?.open(
			urlComponents: urlComponents,
			from: url,
			usingApplicationWithBundleIdentifier: URLOpener.KnownBundleIdentifier.appStore.rawValue
		)
	}
}
