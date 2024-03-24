//
//  Snapshot.swift
//  Snapshot
//
//  Created by Pat Nakajima on 9/7/21.
//

import SwiftUI

extension View {
	@MainActor public func snapshot() -> UIImage? {
		let renderer = ImageRenderer(content: self)
		renderer.scale = 3.0
		return renderer.uiImage
	}
}
