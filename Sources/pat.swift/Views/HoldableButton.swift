//
//  HoldableButton.swift
//  HoldableButton.swift
//
//  Created by Pat Nakajima on 7/16/23.
//

import SwiftUI

public struct HoldableButton<Content: View>: View {
	@State private var startedHoldingAt: Date?
	@Binding var isOn: Bool
	@ViewBuilder var content: () -> Content

	public var body: some View {
		content()
			.gesture(DragGesture(minimumDistance: 0).onChanged { _ in
				if startedHoldingAt != nil {
					return
				}

				Haptics.shared.click()
				self.isOn = true
				self.startedHoldingAt = Date()
			}.onEnded { _ in
				if let startedHoldingAt {
					if Date().addingTimeInterval(-0.2) < startedHoldingAt {
						return
					}

					Haptics.shared.click()
					self.isOn = false
					self.startedHoldingAt = nil
				}
			})
			.onChange(of: isOn) { isOn in
				if !isOn {
					self.startedHoldingAt = nil
				}
			}
	}
}

struct HoldableButton_Previews: PreviewProvider {
	struct Container: View {
		@State private var isOn = false

		var body: some View {
			VStack {
				Text("Is on: \(isOn ? "ON" : "OFF")")
				HoldableButton(isOn: $isOn) {
					Text("HOLD")
						.padding()
						.background(.black)
						.cornerRadius(12)
						.foregroundStyle(.white)
				}
			}
		}
	}

	static var previews: some View {
		Container()
	}
}
