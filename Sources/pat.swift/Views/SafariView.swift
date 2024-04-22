//
//  SafariView.swift
//  Evolreader
//
//  Created by Pat Nakajima on 4/20/24.
//

#if canImport(SafariServices)
import SwiftUI
import SafariServices

public struct SafariViewController: UIViewControllerRepresentable {
	var url: URL
	var dismiss: (() -> Void)?

	// Without these changes, i was having trouble swiping back from a safari view
	// in a navigation stack
	public class NavigatableSafariViewController: SFSafariViewController, UIGestureRecognizerDelegate {
		public init(url: URL, canDismiss: Bool) {
			self.canDismiss = canDismiss
			super.init(url: url, configuration: .init())
		}

		var canDismiss: Bool
		var oldInteractivePopGestureRecognizerDelegate: (any UIGestureRecognizerDelegate)?

		public override func viewDidAppear(_ animated: Bool) {
			self.oldInteractivePopGestureRecognizerDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
			navigationController?.interactivePopGestureRecognizer?.delegate = self
		}

		public override func viewWillDisappear(_ animated: Bool) {
			navigationController?.interactivePopGestureRecognizer?.delegate = oldInteractivePopGestureRecognizerDelegate
		}

		public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
			return canDismiss
		}
	}

	@MainActor public final class Coordinator: NSObject, SFSafariViewControllerDelegate, UIGestureRecognizerDelegate {
		var url: URL
		var dismiss: (() -> Void)?
		var controller: NavigatableSafariViewController

		@MainActor init(url: URL, dismiss: (() -> Void)?) {
			self.url = url
			self.dismiss = dismiss
			self.controller = NavigatableSafariViewController(url: url, canDismiss: dismiss != nil)
			super.init()
			controller.delegate = self
			controller.modalPresentationStyle = .pageSheet
			controller.navigationController?.interactivePopGestureRecognizer?.delegate = self
			controller.dismissButtonStyle = .done
		}

		public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
			print("gestureRecognizerShouldBegin")
			return true
		}

		public func safariViewControllerDidFinish(_: NavigatableSafariViewController) {
			dismiss?()
		}
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(url: url, dismiss: dismiss)
	}

	public func makeUIViewController(context: Context) -> NavigatableSafariViewController {
		context.coordinator.controller
	}

	public func updateUIViewController(_: NavigatableSafariViewController, context _: Context) {}
}

public struct SafariView: View {
	var url: URL
	var dismiss: (() -> Void)?

	public init(url: URL, dismiss: (() -> Void)? = nil) {
		self.url = url
		self.dismiss = dismiss
	}

	public var body: some View {
		SafariViewController(url: url, dismiss: dismiss)
			.ignoresSafeArea(.all)
			.toolbar(.hidden, for: .navigationBar)
	}
}

	#if DEBUG
		#Preview {
			SafariView(url: URL(string: "https://stackoverflow.com/questions/56518029/how-do-i-use-sfsafariviewcontroller-with-swiftui")!)
		}
	#endif
#endif
