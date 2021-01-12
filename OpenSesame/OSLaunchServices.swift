//
//  OSLaunchServices.swift
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

	static func getHTMLHandlers() -> [Bundle] {
		let htmlUTI = "public.html" as CFString

		guard let htmlViewersCFArray = LSCopyAllRoleHandlersForContentType(htmlUTI, .viewer),
			  let htmlViewers = htmlViewersCFArray.takeRetainedValue() as? [String] else {
			return []
		}

		var viewerBundles: [Bundle] = []
		for viewer in htmlViewers {
			guard let viewerURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: viewer),
				  let viewerBundle = Bundle(url: viewerURL),
				  let urlTypes = viewerBundle.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: AnyObject]] else {
				continue
			}
			let urlSchemes = urlTypes.compactMap { $0["CFBundleURLSchemes"] as? [String] }
			if urlSchemes.contains(where: { $0.contains("http") }) {
				viewerBundles.append(viewerBundle)
			}
		}

		return viewerBundles
	}
}
