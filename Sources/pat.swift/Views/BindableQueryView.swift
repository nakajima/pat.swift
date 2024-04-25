//
//  BindableQueryView.swift
//  Evolreader
//
//  Created by Pat Nakajima on 4/19/24.
//

import Foundation
import SwiftData
import SwiftUI

public struct BindableQueryView<Model: PersistentModel, Content: View>: View {
	typealias ContentCallback = ([Model]) -> Content

	var predicate: Predicate<Model>?
	var sort: [SortDescriptor<Model>]
	var animation: Animation

	@ViewBuilder var content: ([Model]) -> Content

	public init(predicate: Predicate<Model>? = nil, sort: [SortDescriptor<Model>] = [], animation: Animation = .default, @ViewBuilder content: @escaping ([Model]) -> Content) {
		self.predicate = predicate
		self.sort = sort
		self.animation = animation
		self.content = content
	}

	struct QueryView: View {
		@Query var models: [Model]

		@ViewBuilder var content: ([Model]) -> Content

		init(
			predicate: Predicate<Model>?,
			sort: [SortDescriptor<Model>] = [],
			content: @escaping ContentCallback,
			animation: Animation = .default
		) {
			_models = Query(filter: predicate, sort: sort, animation: animation)
			self.content = content
		}

		var body: some View {
			content(models)
		}
	}

	public var body: some View {
		QueryView(predicate: predicate, sort: sort, content: content, animation: animation)
	}
}
