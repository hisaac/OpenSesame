//
//  URLOpener.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 12/29/20.
//

import AppKit
import Defaults
import LSFoundation

final class URLOpener: URLHandlerDelegate {

	struct URLOpenAttempt {
		let url: URL
		let attemptTime = Date()
		var usedFallback = false

		init(url: URL) {
			self.url = url
		}
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

	// swiftlint:disable:next cyclomatic_complexity function_body_length
	func open(_ url: URL, usingFallbackHandler: Bool) {
		if url != urlOpenAttempt?.url {
			urlOpenAttempt = URLOpenAttempt(url: url)
		}

		guard Defaults[.urlHandlingEnabled] else { return }

		if usingFallbackHandler {
			openWithFallbackBrowser(url: url)
			return
		}

		// swiftlint:disable statement_position
		if shortlinkHandler.canHandle(url) {
			shortlinkHandler.handle(url)
			return
		}

		if workspace.urlForApplication(withBundleIdentifier: KnownBundleIdentifier.music.rawValue) != nil,
		   appleMusicHandler.canHandle(url) {
			appleMusicHandler.handle(url)
			return
		}

		if workspace.urlForApplication(withBundleIdentifier: KnownBundleIdentifier.news.rawValue) != nil,
		   appleNewsHandler.canHandle(url) {
			appleNewsHandler.handle(url)
			return
		}

		if workspace.urlForApplication(withBundleIdentifier: KnownBundleIdentifier.appStore.rawValue) != nil,
		   appStoreHandler.canHandle(url) {
			appStoreHandler.handle(url)
			return
		}

		if workspace.urlForApplication(withBundleIdentifier: KnownBundleIdentifier.music.rawValue) != nil,
		   appleMusicHandler.canHandle(url) {
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

		if workspace.urlForApplication(withBundleIdentifier: KnownBundleIdentifier.spotify.rawValue) != nil,
		   spotifyHandler.canHandle(url) {
			spotifyHandler.handle(url)
			return
		}

		if workspace.urlForApplication(withBundleIdentifier: KnownBundleIdentifier.twitter.rawValue) != nil,
		   twitterHandler.canHandle(url) {
			twitterHandler.handle(url)
			return
		}

		if workspace.urlForApplication(withBundleIdentifier: KnownBundleIdentifier.zoom.rawValue) != nil,
		   zoomHandler.canHandle(url) {
			zoomHandler.handle(url)
			return
		}

		openWithFallbackBrowser(url: url)
	}

	private func openWithFallbackBrowser(url: URL) {
		urlOpenAttempt?.usedFallback = true
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

	var urlOpenAttempt: URLOpenAttempt?

	func open(url: URL, usingApplicationAt applicationURL: URL) {
		// Checking `NSApp.isActive` must be done on the main thread
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			let openConfiguration = NSWorkspace.OpenConfiguration()
			openConfiguration.activates = NSApp.isActive

			self.workspace.open(
				[url],
				withApplicationAt: applicationURL,
				configuration: openConfiguration,
				completionHandler: self.workspaceOpenCompletionHandler(runningApplication:error:)
			)
		}
	}

	func workspaceOpenCompletionHandler(runningApplication: NSRunningApplication?, error: Error?) {
		if error == nil {
			// If we have no error, then the attempt was successful,
			// and we can nil this out
			urlOpenAttempt = nil
		} else {
			// IF there was an error,
			// AND it was not thrown while trying to use the fallback browser,
			// THEN try opening it with the fallback browser to recover
			if urlOpenAttempt?.usedFallback == false {
				urlOpenAttempt?.usedFallback = true
				guard let url = urlOpenAttempt?.url else { return }
				open(url, usingFallbackHandler: true)
			}
		}

		DispatchQueue.main.async {
			NSApp.deactivate()
		}
	}
}
