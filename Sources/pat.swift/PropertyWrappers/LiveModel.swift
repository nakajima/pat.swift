//
//  LiveModel.swift
//
//
//  Created by Pat Nakajima on 4/26/24.
//

import Combine
import CoreData
import SwiftData
import SwiftUI

// Keep a SwiftData record up to date
@propertyWrapper @Observable public final class LiveModel<T: PersistentModel> {
	var _model: T

	@MainActor public var wrappedValue: T {
		get { _model }
		set { _model = newValue }
	}

	var cancellable: AnyCancellable?

	@MainActor public init(wrappedValue: T) {
		self._model = wrappedValue

		if let context = wrappedValue.modelContext {
			self.cancellable = NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave).sink { [weak self] notification in
				guard let userInfo = notification.userInfo, let self else {
					return
				}

				if let updated = userInfo["updated"],
					 // Convert to an actual swift set
					 let set = (updated as? NSSet as? Set<NSManagedObject>),
					 // See if this update is for our model
					 let object = set.first(where: { $0.objectID.persistentIdentifier == self._model.id }),
					 // We know we have a persistent identifier because of the above check, so try to reload
					 // our model from its context.
					 let model: T = context.registeredModel(for: object.objectID.persistentIdentifier!)
				{
					// Update our model, so the Observation system can let the view know.
					self._model = model
				}
			}
		}
	}

	deinit {
		cancellable?.cancel()
	}
}

//  From https://github.com/fatbobman/SwiftDataKit/blob/main/Sources/SwiftDataKit/CoreData/NSManagedObjectID.swift

private extension NSManagedObjectID {
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
private extension NSManagedObjectID {
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
private struct PersistentIdentifierJSON: Codable {
	struct Implementation: Codable {
		var primaryKey: String
		var uriRepresentation: URL
		var isTemporary: Bool
		var storeIdentifier: String
		var entityName: String
	}

	var implementation: Implementation
}

#if DEBUG
import SwiftData

@Model fileprivate final class Person {
	var name: String
	var friendCount: Int = 0

	init(name: String) {
		self.name = name
	}
}

fileprivate struct PeopleView: View {
	@Query var people: [Person]
	@Environment(\.modelContext) var modelContext

	var body: some View {
		NavigationStack {
			List {
				Section {
					ForEach(people, id: \.name) { person in
						PersonView(person: person)
					}
				}

				Button("Add a random friend") {
					let container = modelContext.container
					let personID = people.randomElement()!.id

					Task {
						let context = ModelContext(container)
						let person = context.model(for: personID) as! Person
						person.friendCount += 1
						print("\(person.name) now has friend count \(person.friendCount)")
						try! context.save()
					}
				}
			}
			.onAppear {
				for name in ["Frasier", "Niles", "Daphne", "Martin", "Eddy"] {
					let person = Person(name: name)
					modelContext.insert(person)
					try! modelContext.save()
				}
			}
		}
	}
}

fileprivate struct PersonView: View {
	@LiveModel var person: Person

	var body: some View {
		HStack {
			Text(person.name)
			Text("\(person.friendCount) friend\(person.friendCount == 1 ? "" : "s")")
		}
	}
}

#Preview {
	PeopleView()
		.modelContainer(for: Person.self, inMemory: true)
}
#endif
