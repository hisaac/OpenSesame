import Defaults
import Foundation

// swiftlint:disable line_length

extension Defaults.Keys {

	// MARK: - General Settings

	/// Whether debug mode is enabled
	static let debugEnabled = Key<Bool>("debugEnabled", default: false)

	/// Whether URL Handling is enabled
	static let urlHandlingEnabled = Key<Bool>("urlHandlingEnabled", default: false)

	/// Tracks if this is the first time the app has been launched
	static let firstLaunch = Key<Bool>("firstLaunch", default: true)

	/// Whether or not to hide the menu item from the menu bar
	static let showMenuItem = Key<Bool>("showMenuItem", default: false)

	/// Whether or not to show the app in the dock
	static let showInDock = Key<Bool>("showInDock", default: false)

	/// What happens when left-clicking on the status item
	static let statusItemLeftClickBehavior = Key<StatusItemLeftClickBehavior>("statusItemLeftClickBehavior", default: .openMenu)

	// MARK: - App Handler Settings

	/// The default browser to fallback to when handling a URL
	/// Defaults to Safari, as that's the only browser we can more or less guarantee will be installed on the system
	static let defaultFallbackBrowserBundleIdentifier = Key<String>("defaultFallbackBrowserBundleIdentifier", default: URLOpener.KnownBundleIdentifier.safari.rawValue)

	// TODO: Find way to gather all url handlers and create defaults settings for them

	static let handleShortLinkURLs = Key<Bool>("handleShortLinkURLs", default: true)
	static let handleAppleMusicURLs = Key<Bool>("handleAppleMusicURLs", default: true)
	static let handleAppleNewsURLs = Key<Bool>("handleAppleNewsURLs", default: false)
	static let handleAppStoreURLs = Key<Bool>("handleAppStoreURLs", default: true)
	static let handleDiscordURLs = Key<Bool>("handleDiscordURLs", default: true)
	static let handleSlackURLs = Key<Bool>("handleSlackURLs", default: true)
	static let handleSpotifyURLs = Key<Bool>("handleSpotifyURLs", default: true)
	static let handleTwitterURLs = Key<Bool>("handleTwitterURLs", default: true)
	static let handleZoomURLs = Key<Bool>("handleZoomURLs", default: true)

	// List of known Slack Teams
	static let slackTeams = Key<Set<SlackTeam>?>("slackTeams")
}

extension Defaults {
	/// Reset `Defaults.Key` items back to their default value.
	func resetToDefaults<T: Serializable>(_ keys: [Defaults.Key<T>]) {
		for key in keys {
			key.reset()
		}
	}
}

enum StatusItemLeftClickBehavior: String, Defaults.Serializable {
	case openMenu
	case toggleFiltering
}

// swiftlint:enable line_length
