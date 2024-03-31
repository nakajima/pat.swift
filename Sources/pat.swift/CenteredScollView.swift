//
//  CenteredScollView.swift
//  CenteredScollView.swift
//
//  Created by Pat Nakajima on 8/28/22.
//

import SwiftUI

public struct CenteredScrollView<Content: View>: View {
	var axis: Axis

	@ViewBuilder var content: () -> Content

	public init(_ axis: Axis, content: @escaping () -> Content) {
		self.axis = axis
		self.content = content
	}

	public var body: some View {
		if axis == .vertical {
			GeometryReader { geometry in
				ScrollView(.vertical) {
					content()
						.frame(width: geometry.size.width)
						.frame(minHeight: geometry.size.height)
				}
			}
		} else {
			GeometryReader { geometry in
				ScrollView(.horizontal) {
					content()
						.frame(height: geometry.size.height)
						.frame(minWidth: geometry.size.width)
				}
			}
		}
	}
}

struct VScrollView_Previews: PreviewProvider {
	static var previews: some View {
		CenteredScrollView(.vertical) {
			Text("Hi")
		}
	}
}
