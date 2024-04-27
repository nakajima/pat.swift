//
//  LiveModel.swift
//  
//
//  Created by Pat Nakajima on 4/26/24.
//

import SwiftData
import SwiftUI
import CoreData
import Combine

// Keep a SwiftData record up to date
@propertyWrapper @Observable public final class LiveModel<T: PersistentModel> {
	@MainActor var _model: T

	@MainActor public var wrappedValue: T {
		get { _model }
		set {	_model = newValue	}
	}

	var animation: Animation?
	var cancellable: AnyCancellable?

	@MainActor public init(wrappedValue: T, animation: Animation? = nil) {
		self._model = wrappedValue
		self.animation = animation

		if let context = wrappedValue.modelContext {
			self.cancellable = NotificationCenter.default.publisher(for: Notification.Name.NSManagedObjectContextDidSave).sink { [weak self] notification in
				guard let userInfo = notification.userInfo else {
					return
				}

				if let updated = userInfo["updated"], let set = updated as? NSSet,
					 let object = Array(set).first as? NSManagedObject,
					 let id = object.objectID.persistentIdentifier,
					 let model = context.model(for: id) as? T {
					guard let self else {
						return
					}

					if let animation = self.animation {
						withAnimation(animation) {
							self._model = model
						}
					} else {
						self._model = model
					}
				}
			}
		}
	}

	deinit {
		cancellable?.cancel()
	}
}

//  From https://github.com/fatbobman/SwiftDataKit/blob/main/Sources/SwiftDataKit/CoreData/NSManagedObjectID.swift

fileprivate extension NSManagedObjectID {
	// Compute PersistentIdentifier from NSManagedObjectID
	var persistentIdentifier: PersistentIdentifier? {
		guard let storeIdentifier, let entityName else { return nil }
		let json = PersistentIdentifierJSON(
			implementation: .init(
				primaryKey: primaryKey,
				uriRepresentation: uriRepresentation(),
				isTemporary: isTemporaryID,
				storeIdentifier: storeIdentifier,
				entityName: entityName
			)
		)
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(json) else { return nil }
		let decoder = JSONDecoder()
		return try? decoder.decode(PersistentIdentifier.self, from: data)
	}
}

// Extensions to expose needed implementation details
fileprivate extension NSManagedObjectID {
	// Primary key is last path component of URI
	var primaryKey: String {
		uriRepresentation().lastPathComponent
	}

	// Store identifier is host of URI
	var storeIdentifier: String? {
		guard let identifier = uriRepresentation().host() else { return nil }
		return identifier
	}

	// Entity name from entity name
	var entityName: String? {
		guard let entityName = entity.name else { return nil }
		return entityName
	}
}

// Model to represent identifier implementation as JSON
fileprivate struct PersistentIdentifierJSON: Codable {
	struct Implementation: Codable {
		var primaryKey: String
		var uriRepresentation: URL
		var isTemporary: Bool
		var storeIdentifier: String
		var entityName: String
	}

	var implementation: Implementation
}
