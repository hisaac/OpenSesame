//
//  URLHandlerDelegate.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import AppKit

protocol URLHandlerDelegate: AnyObject {
	var workspace: NSWorkspace { get }

	func open(urlComponents: URLComponents?, from originalURL: URL, usingApplicationWithBundleIdentifier bundleIdentifier: String)
	func open(url: URL, usingApplicationWithBundleIdentifier bundleIdentifier: String)
	func open(url: URL, usingApplicationAt applicationURL: URL)
	func open(_ url: URL, usingFallbackHandler: Bool)
}

extension URLHandlerDelegate {
	// Convenience method to pass `false` if no `usingFallbackHandler` value is given
	func open(_ url: URL) {
		open(url, usingFallbackHandler: false)
	}
}
