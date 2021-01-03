//
//  LaunchServicesMethods.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/3/21.
//

import AppKit

enum OSLaunchServices {
	static var defaultHTMLViewerApp: String? {
		return defaultHTMLViewerAppURL?.absoluteString.lastPathComponent.removingPercentEncoding
	}

	static var defaultHTMLViewerAppURL: URL? {
		let htmlUTI = "public.html" as CFString
		let defaultHTMLAppCFURL = LSCopyDefaultApplicationURLForContentType(htmlUTI, .viewer, nil)
		let defaultHTMLAppURL = defaultHTMLAppCFURL?.takeRetainedValue() as URL?
		return defaultHTMLAppURL
	}

	// TODO: Implement
	static func setOpenSesameAsDefaultHTMLViewer() {

	}
}
