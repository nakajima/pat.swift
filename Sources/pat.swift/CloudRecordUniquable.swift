//
//  CloudRecordUniquable.swift
//
//  Created by Pat Nakajima on 4/17/24.
//

#if canImport(SwiftData)
	import Foundation
	import OSLog
	import SwiftData

	public protocol CloudRecordUniquable {
		associatedtype StableValue: Hashable
		associatedtype ComparisonValue: Comparable

		// An Attribute of the Model that is stable between different different installs
		static var stableID: KeyPath<Self, StableValue> { get }

		// A Comparable Attribute of the Model that is determined which records to keep.
		// Greater values win, lesser values are deleted.
		static var comparisonPath: KeyPath<Self, ComparisonValue> { get }
	}

public extension CloudRecordUniquable where Self: PersistentModel {
		@MainActor static func prune(in container: ModelContainer, logger: Logger? = nil) throws {
			let logger = logger ?? Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(self)-pruner")

			logger.debug("Pruning \(self)")

			let context = container.mainContext
			let descriptor = FetchDescriptor<Self>()
			let records = try context.fetch(descriptor)

			logger.debug("Found \(records.count) total records")

			if records.isEmpty {
				return
			}

			let recordsByComparator: [StableValue: (PersistentIdentifier, ComparisonValue)] = records.reduce(into: [:]) { result, record in
				let stableID = record[keyPath: stableID]
				let comparisonValue = record[keyPath: comparisonPath]

				guard let (_, known) = result[stableID] else {
					result[stableID] = (record.id, comparisonValue)
					return
				}

				if known < comparisonValue {
					return
				}

				result[stableID] = (record.id, comparisonValue)
			}

			let currentRecordIDs = recordsByComparator.map(\.value.0)

			logger.debug("Found \(currentRecordIDs.count) current records")

			try context.delete(model: Self.self, where: #Predicate { record in
				!currentRecordIDs.contains(record.persistentModelID)
			})

			try context.save()

			logger.debug("Done")
		}
	}
#endif
