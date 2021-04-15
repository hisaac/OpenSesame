//
//  URLOpener.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 12/29/20.
//

import AppKit
import LSFoundation

final class URLOpener: URLHandlerDelegate {

	enum KnownBundleIdentifier: String {
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
	}

	internal let workspace: NSWorkspace

	// Generic handlers
	private let shortlinkHandler: URLHandler
	private let fallbackHandler: URLHandler

	// App-specific handlers
	private let appleMusicHandler: URLHandler
	private let appleNewsHandler: URLHandler
	private let appStoreHandler: URLHandler
	private let discordHandler: URLHandler
	private let slackHandler: URLHandler
	private let spotifyHandler: URLHandler
	private let twitterHandler: URLHandler
	private let zoomHandler: URLHandler

	init() {
		workspace = NSWorkspace.shared
		shortlinkHandler = ShortlinkHandler()
		fallbackHandler = FallbackHandler()
		appleMusicHandler = AppleMusicHandler()
		appleNewsHandler = AppleNewsHandler()
		appStoreHandler = AppStoreHandler()
		discordHandler = DiscordHandler()
		slackHandler = SlackHandler()
		spotifyHandler = SpotifyHandler()
		twitterHandler = TwitterHandler()
		zoomHandler = ZoomHandler()
		setDelegates()
	}

	func setDelegates() {
		shortlinkHandler.delegate = self
		fallbackHandler.delegate = self
		appleMusicHandler.delegate = self
		appleNewsHandler.delegate = self
		appStoreHandler.delegate = self
		discordHandler.delegate = self
		slackHandler.delegate = self
		spotifyHandler.delegate = self
		twitterHandler.delegate = self
		zoomHandler.delegate = self
	}

	func canOpen(_ url: URL) -> Bool {
		return shortlinkHandler.canHandle(url)
			|| fallbackHandler.canHandle(url)
			|| appleMusicHandler.canHandle(url)
			|| appleNewsHandler.canHandle(url)
			|| appStoreHandler.canHandle(url)
			|| discordHandler.canHandle(url)
			|| slackHandler.canHandle(url)
			|| spotifyHandler.canHandle(url)
			|| twitterHandler.canHandle(url)
			|| zoomHandler.canHandle(url)
	}

	func open(_ urls: [URL]) {
		for url in urls {
			open(url)
		}
	}

	// swiftlint:disable:next cyclomatic_complexity
	func open(_ url: URL, usingFallbackHandler: Bool) {
		guard Settings.urlHandlingEnabled,
			  usingFallbackHandler == false else {
			fallbackHandler.handle(url)
			return
		}

		// swiftlint:disable statement_position
		if shortlinkHandler.canHandle(url) {
			shortlinkHandler.handle(url)
			return
		}

		if appleMusicHandler.canHandle(url) {
			appleMusicHandler.handle(url)
			return
		}

		if appleNewsHandler.canHandle(url) {
			appleNewsHandler.handle(url)
			return
		}

		if appStoreHandler.canHandle(url) {
			appStoreHandler.handle(url)
			return
		}

		if appleMusicHandler.canHandle(url) {
			appleMusicHandler.handle(url)
			return
		}

		// TODO: Implement
		if discordHandler.canHandle(url) {
			discordHandler.handle(url)
			return
		}

		// TODO: Implement
		if slackHandler.canHandle(url) {
			slackHandler.handle(url)
			return
		}

		if spotifyHandler.canHandle(url) {
			spotifyHandler.handle(url)
			return
		}

		if twitterHandler.canHandle(url) {
			twitterHandler.handle(url)
			return
		}

		if zoomHandler.canHandle(url) {
			zoomHandler.handle(url)
			return
		}

		fallbackHandler.handle(url)
	}

	// MARK: - Open methods

	func open(urlComponents: URLComponents?,
					  from originalURL: URL,
					  usingApplicationWithBundleIdentifier bundleIdentifier: String) {
		guard let urlFromComponents = urlComponents?.url else {
			// TODO: Implement real logging
			print("Unable to generate URL from URLComponents. Opening original URL in default browser instead.")
			fallbackHandler.handle(originalURL)
			return
		}

		open(url: urlFromComponents, usingApplicationWithBundleIdentifier: bundleIdentifier)
	}

	func open(url: URL, usingApplicationWithBundleIdentifier bundleIdentifier: String) {
		guard let applicationURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
			fallbackHandler.handle(url)
			return
		}
		open(url: url, usingApplicationAt: applicationURL)
	}

	func open(url: URL, usingApplicationAt applicationURL: URL) {
		// Checking `NSApp.isActive` must be done on the main thread
		DispatchQueue.main.async { [weak self] in
			let openConfiguration = NSWorkspace.OpenConfiguration()
			openConfiguration.activates = NSApp.isActive

			self?.workspace.open(
				[url],
				withApplicationAt: applicationURL,
				configuration: openConfiguration,
				completionHandler: self?.workspaceOpenCompletionHandler(runningApplication:error:)
			)
		}
	}

	func workspaceOpenCompletionHandler(runningApplication: NSRunningApplication?, error: Error?) {
		// `NSApp.deactivate()` (and possibly `presentError` as well) require being called on the main thread
		DispatchQueue.main.async {
			if let error = error {
				NSApp.presentError(error)
			} else {
				NSApp.deactivate()
			}
		}
	}
}
