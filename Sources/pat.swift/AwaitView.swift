//
//  SwiftUIView.swift
//  
//
//  Created by Pat Nakajima on 4/20/24.
//

import SwiftUI

public struct AwaitView<T, Content: View, Placeholder: View>: View {
	enum Status {
		case waiting, done(T), canceled, errored(Error)
	}

	var valueBlock: () async throws -> T
	@ViewBuilder var content: (T) -> Content
	var placeholder: (() -> Placeholder)?

	@State var status: Status = .waiting

	public init(
		value valueBlock: @escaping () async -> T,
		@ViewBuilder content: @escaping (T) -> Content,
		placeholder: (() -> Placeholder)?
	) {
		self.valueBlock = valueBlock
		self.content = content
		self.placeholder = placeholder
	}

	public var body: some View {
		switch status {
		case .waiting:
			placeholderView
				.task {
					await getValue()
				}
		case .done(let value):
			content(value)
		case .canceled:
			Text("Canceled")
		case .errored(let error):
			Text("Errored: \(error)")
		}
	}

	@ViewBuilder var placeholderView: some View {
		if let placeholder {
			placeholder()
		} else {
			ProgressView()
		}
	}

	func getValue() async {
		do {
			let value = try await valueBlock()
			self.status = Task.isCancelled ? .canceled : .done(value)
		} catch {
			if error is CancellationError {
				self.status = .canceled
			} else {
				self.status = .errored(error)
			}
		}
	}
}

extension AwaitView where Placeholder == Never {
	public init(
		value valueBlock: @escaping () async -> T,
		@ViewBuilder content: @escaping (T) -> Content
	) {
		self.valueBlock = valueBlock
		self.content = content
	}
}

#if DEBUG
struct AwaitViewPreviews: PreviewProvider {
	static var previews: some View {
		AwaitView {
			try! await Task.sleep(for: .seconds(2))
			return "The Time is \(Date().formatted())"
		} content: { value in
			Text(value)
		}

		AwaitView {
			try! await Task.sleep(for: .seconds(2))
			return "The Time is \(Date().formatted())"
		} content: { value in
			Text(value)
		} placeholder: {
			Text("Loading the time.")
		}
	}
}
#endif
