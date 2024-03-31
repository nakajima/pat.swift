//
//  SheetButton.swift
//  SheetButton.swift
//
//  Created by Pat Nakajima on 6/21/22.
//

import SwiftUI

public class SheetButtonContext: ObservableObject {
	@Published var isPresented = false

	public func dismiss() {
		isPresented = false
	}
}

public struct SheetButton<ButtonContent: View, SheetContent: View>: View {
	@StateObject private var context = SheetButtonContext()

	public var buttonLabel: () -> ButtonContent
	public var sheetContent: () -> SheetContent
	public var beforePresent: (() -> Void)?

	public init(
		buttonLabel: @escaping () -> ButtonContent,
		sheetContent: @escaping () -> SheetContent,
		beforePresent: (() -> Void)? = nil
	) {
		self.buttonLabel = buttonLabel
		self.sheetContent = sheetContent
		self.beforePresent = beforePresent
	}

	public var body: some View {
		Button(action: {
			if let beforePresent {
				beforePresent()
			}

			withAnimation {
				context.isPresented.toggle()
			}
		}) {
			buttonLabel()
		}
		.sheet(isPresented: $context.isPresented) {
			sheetContent()
				.environmentObject(context)
		}
	}
}

struct SheetButton_Previews: PreviewProvider {
	static var previews: some View {
		SheetButton(buttonLabel: {
			Text("Hi")
		}, sheetContent: {
			Text("Hello")
		})
	}
}
