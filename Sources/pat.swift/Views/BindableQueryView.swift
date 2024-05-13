//
//  BindableQueryView.swift
//  Evolreader
//
//  Created by Pat Nakajima on 4/19/24.
//

import Foundation
import SwiftData
import SwiftUI

public struct BindableQueryView<Model: PersistentModel, Content: View, Empty: View>: View {
	typealias ContentCallback = ([Model]) -> Content

	var predicate: Predicate<Model>?
	var sort: [SortDescriptor<Model>]
	var animation: Animation

	@ViewBuilder var content: ([Model]) -> Content
	var empty: (() -> Empty)?

	public init(
		predicate: Predicate<Model>? = nil,
		sort: [SortDescriptor<Model>] = [],
		animation: Animation = .default,
		@ViewBuilder content: @escaping ([Model]) -> Content,
		@ViewBuilder empty: @escaping () -> Empty
	) {
		self.predicate = predicate
		self.sort = sort
		self.animation = animation
		self.content = content
		self.empty = empty
	}

	struct QueryView: View {
		@Query var models: [Model]

		@ViewBuilder var content: ([Model]) -> Content
		var empty: (() -> Empty)?

		init(
			predicate: Predicate<Model>?,
			sort: [SortDescriptor<Model>] = [],
			content: @escaping ContentCallback,
			empty: (() -> Empty)?,
			animation: Animation = .default
		) {
			_models = Query(filter: predicate, sort: sort, animation: animation)
			self.content = content
			self.empty = empty
		}

		var body: some View {
			content(models)
				.overlay {
					if models.isEmpty, let empty {
						empty()
					}
				}
		}
	}

	public var body: some View {
		QueryView(predicate: predicate, sort: sort, content: content, empty: empty, animation: animation)
	}
}

extension BindableQueryView where Empty == Never {
	public init(
		predicate: Predicate<Model>? = nil,
		sort: [SortDescriptor<Model>] = [],
		animation: Animation = .default,
		@ViewBuilder content: @escaping ([Model]) -> Content
	) {
		self.predicate = predicate
		self.sort = sort
		self.animation = animation
		self.content = content
		self.empty = nil
	}
}
