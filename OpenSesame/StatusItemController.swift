//
//  StatusItemController.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/3/21.
//

import AppKit
import os.log

typealias StatusItemControllerDelegate = Enablable & PreferencesWindowDelegate

class StatusItemController {

	weak var delegate: StatusItemControllerDelegate?
	private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
	private (set) var isEnabled = false
	private let logger: OSLog

	init(logger: OSLog) {
		self.logger = logger
		statusItem.button?.image = NSImage(named: "StatusBarButtonImage")
		statusItem.menu = buildMenu()
	}

	private func buildMenu() -> NSMenu {
		let menu = NSMenu()
		menu.items = [
			NSMenuItem(
				title: LocalizedStrings.appVersion,
				target: self,
				isEnabled: false
			),
			NSMenuItem.separator(),
			enabledMenuItem,
			NSMenuItem.separator(),
			debugMenuItem,
			NSMenuItem.separator(),
			NSMenuItem(
				title: "Preferences…",
				action: #selector(openPreferencesWindow),
				keyEquivalent: ",",
				target: self
			),
			NSMenuItem(
				title: LocalizedStrings.aboutOpenSesameMenuItemTitle,
				action: #selector(openAboutPanel),
				target: self
			),
			NSMenuItem(
				title: LocalizedStrings.quitMenuItemTitle,
				action: #selector(NSApp.terminate),
				keyEquivalent: "q",
				target: NSApp
			)
		]
		return menu
	}

	private lazy var enabledMenuItem: NSMenuItem = {
		return NSMenuItem(
			title: LocalizedStrings.enabledMenuItemTitle,
			action: #selector(toggleIsEnabled),
			target: self
		)
	}()

	private lazy var debugMenuItem: NSMenuItem = {
		return NSMenuItem(
			title: LocalizedStrings.debugMenuItemTitle,
			action: #selector(toggleDebugMode),
			target: self
		)
	}()

	// MARK: - Menu Item Actions

	@objc
	private func openPreferencesWindow() {
		delegate?.openPreferencesWindow()
	}

	/// Opens Plain Pasta's About page, currently the app's website
	@objc
	private func openAboutPanel() {
		NSApp.activate(ignoringOtherApps: true)
		NSApp.orderFrontStandardAboutPanel(self)
	}

	/// Toggles debug mode for the app
	@objc
	private func toggleDebugMode() {
		Settings.debugEnabled.toggle()
		if Settings.debugEnabled {
			debugMenuItem.state = .on
		} else {
			debugMenuItem.state = .off
		}
	}

	/// Toggles the enabled state of the menu
	@objc
	private func toggleIsEnabled() {
		if isEnabled {
			disable()
		} else {
			enable()
		}
	}
}

extension StatusItemController: Enablable {
	func enable() {
		guard isEnabled == false else { return }
		isEnabled = true
		enabledMenuItem.state = .on
		delegate?.enable()
	}

	func disable() {
		guard isEnabled == true else { return }
		isEnabled = false
		enabledMenuItem.state = .off
		delegate?.disable()
	}
}

extension NSMenuItem {
	convenience init(title: String,
					 action: Selector? = nil,
					 keyEquivalent: String = "",
					 target: AnyObject? = nil,
					 isEnabled: Bool = true) {
		self.init(title: title, action: action, keyEquivalent: keyEquivalent)
		self.target = target
		self.isEnabled = isEnabled
	}
}
