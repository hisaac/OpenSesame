//
//  Enablable.swift
//  Open Sesame
//
//  Created by Isaac Halvorson on 1/3/21.
//

protocol Enablable: class {
	var isEnabled: Bool { get }
	func enable()
	func disable()
}
