//
//  String.swift
//
//
//  Created by Pat Nakajima on 3/28/24.
//

import Foundation

public extension String {
	var isBlank: Bool {
		trimmingCharacters(in: .whitespacesAndNewlines) == ""
	}
}
