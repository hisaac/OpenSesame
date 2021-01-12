//
//  URLHandler.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/12/21.
//

import Foundation

protocol URLHandler: class {
	var delegate: URLHandlerDelegate? { get set }
	func canHandle(_ url: URL) -> Bool
	func handle(_ url: URL)
}
