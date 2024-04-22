//
//  SafariView.swift
//  Evolreader
//
//  Created by Pat Nakajima on 4/20/24.
//

#if canImport(SafariServices)
import SafariServices
import SwiftUI

public struct SafariViewController: UIViewControllerRepresentable {
	var url: URL
	var dismiss: (() -> Void)?

	public final class Coordinator: NSObject, SFSafariViewControllerDelegate {
		var url: URL
		var dismiss: (() -> Void)?
		var controller: SFSafariViewController

		@MainActor init(url: URL, dismiss: (() -> Void)?) {
			self.url = url
			self.dismiss = dismiss
			self.controller = SFSafariViewController(url: url)
			super.init()
			controller.delegate = self
			controller.modalPresentationStyle = .formSheet
			controller.dismissButtonStyle = .done
		}

		public func safariViewControllerDidFinish(_: SFSafariViewController) {
			dismiss?()
		}
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(url: url, dismiss: dismiss)
	}

	public func makeUIViewController(context: Context) -> SFSafariViewController {
		context.coordinator.controller
	}

	public func updateUIViewController(_: SFSafariViewController, context _: Context) {}
}

extension UINavigationController: UIGestureRecognizerDelegate {
	override open func viewDidLoad() {
		super.viewDidLoad()
		interactivePopGestureRecognizer?.delegate = self
	}

	public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
		return viewControllers.count > 1
	}
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
