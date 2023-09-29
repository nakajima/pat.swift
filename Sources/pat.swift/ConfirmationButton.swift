//
//  ConfirmationButton.swift
//  Wub4
//
//  Created by Pat Nakajima on 7/17/23.
//

import SwiftUI

public struct ConfirmationButton<ButtonContent: View, ConfirmationContent: View>: View {
	@State private var isConfirming = false

	public var title: String
	@ViewBuilder public var buttonContent: (@escaping () -> Void) -> ButtonContent
	@ViewBuilder public var confirmationContent: () -> ConfirmationContent

	public init(
		_ title: String,
		@ViewBuilder buttonContent: @escaping (@escaping () -> Void) -> ButtonContent,
		@ViewBuilder confirmationContent: @escaping () -> ConfirmationContent
	) {
		self.title = title
		self.buttonContent = buttonContent
		self.confirmationContent = confirmationContent
	}

	public var body: some View {
		buttonContent { isConfirming = true }
			.confirmationDialog(title, isPresented: $isConfirming, titleVisibility: .visible) {
				confirmationContent()
			}
	}
}

#Preview {
	ConfirmationButton("Sure about that?") { action in
		Button("Hello", action: action)
	} confirmationContent: {
		Button("OK") {}
		Button("Cancel", role: .cancel) {}
	}
}
