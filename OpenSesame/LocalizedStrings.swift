//
//  LocalizedStrings.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/3/21.
//

import Foundation

enum LocalizedStrings {

	// MARK: - Menu Item Titles

	/// Localized version of "About Open Sesame…"
	/// For use as the title for the "About Open Sesame…" menu item
	static let aboutOpenSesameMenuItemTitle = NSLocalizedString(
		"aboutOpenSesameMenuItemTitle",
		value: "About Open Sesame…",
		comment: #"Title for the "About" menu item"#
	)

	/// Localized version of "Enabled"
	/// For use as the title for the "Enabled" menu item
	static let enabledMenuItemTitle = NSLocalizedString(
		"enabledMenuItemTitle",
		value: "Enabled",
		comment: #"Title for the "Enabled" menu item"#
	)

	/// Localized version of "Quit"
	/// For use as the title for the "Quit" menu item
	static let quitMenuItemTitle = NSLocalizedString(
		"quitMenuItemTitle",
		value: "Quit",
		comment: #"Title for the "Quit" menu item"#
	)

	/// Localized version of "Debug"
	/// For us as the title for the "Debug" menu item
	static let debugMenuItemTitle = NSLocalizedString(
		"debugMenuItemTitle",
		value: "Debug",
		comment: #"Title for the "Debug" menu item"#
	)

	// MARK: - Version Number

	/// Localized version of the word "Version"
	/// For use in representing the app's version number
	static let versionTitle = NSLocalizedString(
		"versionTitle",
		value: "Version",
		comment: "The word for 'Version'"
	)

	/// Localized version of the app's version number
	/// Formatted as: "Version 1.0.1"
	static var appVersion: String {
		let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
		return "\(versionTitle) \(versionNumber)"
	}
}
