//
//  StateContainer.swift
//
//
//  Created by Pat Nakajima on 4/21/24.
//

import Foundation
import Observation
import SwiftUI

@Observable public class StateContainerValue<Value> {
	public var value: Value

	init(value: Value) {
		self.value = value
	}
}

public struct StateContainer<Content: View, Value>: View {
	@State var container: StateContainerValue<Value>
	var content: (StateContainerValue<Value>) -> Content

	public init(initial: Value, @ViewBuilder content: @escaping (StateContainerValue<Value>) -> Content) {
		self.container = StateContainerValue(value: initial)
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
			Text("Hi")
		}
	}
#endif
