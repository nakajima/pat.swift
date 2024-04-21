//
//  Navigation.swift
//
//
//  Created by Pat Nakajima on 4/20/24.
//

#if canImport(SwiftUI)
	import Observation
	import SwiftUI

	public protocol NavigationRoute: Hashable {}

	@Observable public final class Navigation<Route: NavigationRoute> {
		public internal(set) var path: [Route] = []

		func append(_ route: Route) {
			path.append(route)
		}
	}

	public extension Navigation {
		func link<Content: View>(to route: Route, label: () -> Content) -> some View {
			NavigationLink(value: route, label: label)
		}

		func link(_ label: String, to route: Route) -> some View {
			NavigationLink(label, value: route)
		}
	}

	public struct NavigationStackWrapper<T: NavigationRoute, Content: View>: View {
		@State var navigation = Navigation<T>()

		@ViewBuilder var content: (Navigation<T>) -> Content

		init(
			for _: T.Type,
			@ViewBuilder content: @escaping (Navigation<T>) -> Content
		) {
			self.content = content
		}

		public var body: some View {
			NavigationStack(path: $navigation.path) {
				content(navigation)
			}
			.environment(navigation)
		}
	}

	#if DEBUG
		enum TestRoute: Hashable, NavigationRoute {
			case home, show(Int)
		}

		#Preview {
			NavigationStackWrapper(for: TestRoute.self) { navigation in
				NavigationLink("Show", value: TestRoute.show(1))
					.navigationDestination(for: TestRoute.self) { route in
						switch route {
						case .home:
							navigation.link(to: .show(1)) {
								Text("Show 1")
							}
						case let .show(i):
							navigation.link("Show \(i)", to: .show(i + 1))
						}
					}
			}
		}
	#endif
#endif
