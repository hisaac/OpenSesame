//
//  GeneralPreferenceViewController.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/3/21.
//

import AppKit
import Preferences

class GeneralPreferenceViewController: NSViewController, PreferencePane {
	var preferencePaneIdentifier = Preferences.PaneIdentifier.general
	var preferencePaneTitle = "General"
	let toolbarItemIcon = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "General preferences")!

	override var nibName: NSNib.Name? { "GeneralPreferenceViewController" }

	override func viewDidLoad() {
		super.viewDidLoad()

		preferredContentSize = NSSize(width: 768, height: 512)
	}

	// TODO: To be used when implementing default browser choice
	//			let handlers = urlHandler.getHTMLHandlers()
	//			print(handlers)
}
