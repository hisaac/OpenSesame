//
//  KnownBundleIdentifier.swift
//  KnownBundleIdentifier
//
//  Created by Isaac.Halvorson on 8/11/21.
//

import AppKit
import Foundation

enum KnownBundleIdentifier: String, CaseIterable {
	case appStore = "com.apple.AppStore"
	case music = "com.apple.Music"
	case news = "com.apple.news"
	case slack = "com.tinyspeck.slackmacgap"
	case spotify = "com.spotify.client"
	case tweetbot = "com.tapbots.Tweetbot3Mac"
	case twitter = "maccatalyst.com.atebits.Tweetie2"
	case zoom = "us.zoom.xos"

	// Browsers
	case chrome = "com.google.Chrome"
	case firefox = "org.mozilla.firefox"
	case opera = "com.operasoftware.Opera"
	case safari = "com.apple.Safari"
	case safariTechnologyPreview = "com.apple.SafariTechnologyPreview"

	var bundle: Bundle? {
		return Bundle(identifier: rawValue)
	}
}
