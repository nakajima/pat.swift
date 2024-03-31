//
//  Date.swift
//
//
//  Created by Pat Nakajima on 3/30/24.
//

import Foundation

// TODO: This should probably be a duration formatter
public extension Date {
	var shortPretty: String {
		guard let i = Calendar.current.dateComponents([.second], from: self, to: Date()).second else {
			return ""
		}

		switch i {
		case 0 ..< 60:
			return "\(i)s"
		case 60 ..< 3600:
			return "\(i / 60)m"
		case 3600 ..< 86400:
			return "\(i / 3600)h"
		case 86400 ..< 604_800:
			return "\(i / 86400)d"
		default:
			let formatter = DateFormatter()
			formatter.dateFormat = "MM/dd/yyyy"
			return formatter.string(from: self)
		}
	}
}
