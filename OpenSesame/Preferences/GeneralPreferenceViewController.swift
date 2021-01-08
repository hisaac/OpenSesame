//
//  GeneralPreferenceViewController.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/3/21.
//

import AppKit
import Preferences

extension Preferences.PaneIdentifier {
	static let general = Self("general")
}

class GeneralPreferenceViewController: NSViewController, PreferencePane {
	var preferencePaneIdentifier = Preferences.PaneIdentifier.general
	var preferencePaneTitle = "General"
	let toolbarItemIcon = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "General preferences")!

	override var nibName: NSNib.Name? { "GeneralPreferenceViewController" }

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// TODO: To be used when implementing default browser choice
	//			let handlers = urlHandler.getHTMLHandlers()
	//			print(handlers)
}
