//
//  UserDefault.swift
//
//
//  Created by Pat Nakajima on 4/20/24.
//

import Foundation

public protocol AnyOptional {
	var isNil: Bool { get }
}

public extension AnyOptional {
	var isNil: Bool { false }
}

extension Optional: AnyOptional {
	public var isNil: Bool { true }
}

@propertyWrapper public struct UserDefault<Value: Codable> {
	public var wrappedValue: Value? {
		get {
			if serialized {
				if let data = storage.data(forKey: key),
					 let value = try? JSONDecoder().decode(Value.self, from: data) {
					return value
				}
			} else {
				if let value = storage.value(forKey: key) {
					return value as? Value
				}
			}

			return nil
		}

		set {
			if serialized {
				storage.setValue(try? JSONEncoder().encode(newValue), forKey: key)
			} else {
				storage.setValue(newValue, forKey: key)
			}
		}
	}

	var key: String
	var storage: UserDefaults
	var serialized: Bool

	public init(
		key: String,
		storage: UserDefaults = .standard,
		serialize: Bool = false
	) {
		self.key = key
		self.storage = storage
		self.serialized = serialize
	}
}
