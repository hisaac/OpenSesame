//
//  SafariExtensionViewController.swift
//  OpenSesame Extension
//
//  Created by Isaac Halvorson on 11/30/20.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {

	static let shared: SafariExtensionViewController = {
		let shared = SafariExtensionViewController()
		shared.preferredContentSize = NSSize(width: 320, height: 240)
		return shared
	}()

}
