//
//  StateContainer.swift
//
//
//  Created by Pat Nakajima on 4/21/24.
//

import Foundation
import SwiftUI
import Observation

public struct StateContainer<Content: View, Value>: View {
	@Observable class Container {
		public var value: Value

		init(value: Value) {
			self.value = value
		}
	}

	@State var container: Container
	@ViewBuilder var content: (Container) -> Content

	init(initial: Value, content: @escaping (Container) -> Content) {
		self.container = Container(value: initial)
		self.content = content
	}

	public var body: some View {
		content(container)
	}
}

#if DEBUG
#Preview {
	StateContainer(initial: 1) { container in
		Button("State is \(container.value)") { container.value += 1 }
	}
}
#endif
