//
//  Settings.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/3/21.
//

import Foundation
import Preferences

struct Settings {

	// MARK: - General Settings

	/// Sets whether debug mode is enabled
	@UserDefaultsBacked(key: "debugEnabled", defaultValue: false)
	static var debugEnabled: Bool

	/// Sets whether pasteboard filtering is enabled
	@UserDefaultsBacked(key: "urlHandlingEnabled", defaultValue: true)
	static var urlHandlingEnabled: Bool

	/// Tracks if this is the first time the app has been launched
	@UserDefaultsBacked(key: "firstLaunch", defaultValue: true)
	static var firstLaunch: Bool

	/// The default browser to fallback to when handling a URL
	/// Defaults to Safari, as that's the only browser we can more or less guarantee will be installed on the system
	@UserDefaultsBacked(
		key: "defaultFallbackBrowserBundleIdentifier",
		defaultValue: URLOpener.KnownBundleIdentifier.safari.rawValue)
	static var defaultFallbackBrowserBundleIdentifier: String

	// MARK: - App Handler Settings

	@UserDefaultsBacked(key: "handleShortLinkURLs", defaultValue: true)
	static var handleShortLinkURLs: Bool

	@UserDefaultsBacked(key: "handleAppleMusicURLs", defaultValue: true)
	static var handleAppleMusicURLs: Bool

	@UserDefaultsBacked(key: "handleAppleNewsURLs", defaultValue: false)
	static var handleAppleNewsURLs: Bool

	@UserDefaultsBacked(key: "handleAppStoreURLs", defaultValue: true)
	static var handleAppStoreURLs: Bool

	@UserDefaultsBacked(key: "handleSlackURLs", defaultValue: true)
	static var handleSlackURLs: Bool

	@UserDefaultsBacked(key: "handleSpotifyURLs", defaultValue: true)
	static var handleSpotifyURLs: Bool

	@UserDefaultsBacked(key: "handleTwitterURLs", defaultValue: true)
	static var handleTwitterURLs: Bool

	@UserDefaultsBacked(key: "handleZoomURLs", defaultValue: true)
	static var handleZoomURLs: Bool
}
