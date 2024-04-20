//
//  UserDefault.swift
//
//
//  Created by Pat Nakajima on 4/20/24.
//

import Foundation

public protocol AnyOptional {

}

extension Optional: AnyOptional {

}

@propertyWrapper public struct UserDefault<Value: Codable> {
	public var wrappedValue: Value {
		get {
			if serialized {
				if let data = storage.data(forKey: key),
					 let value = try? JSONDecoder().decode(Value.self, from: data) {
					return value
				}
			} else {
				if let value = storage.value(forKey: key) as? Value {
					return value
				}
			}

			return defaultValue
		}

		set {
			if serialized {
				storage.setValue(try? JSONEncoder().encode(newValue), forKey: key)
			} else {
				storage.setValue(newValue, forKey: key)
			}
		}
	}

	var defaultValue: Value
	var key: String
	var storage: UserDefaults
	var serialized: Bool

	public init(
		wrappedValue defaultValue: Value,
		key: String,
		storage: UserDefaults = .standard,
		serialize: Bool = false
	) {
			self.defaultValue = defaultValue
			self.key = key
			self.storage = storage
			self.serialized = serialize
	}
}

extension UserDefault where Value: ExpressibleByNilLiteral {
	public init(
		key: String,
		storage: UserDefaults = .standard,
		serialize: Bool = false
	) {
		self.defaultValue = nil
		self.key = key
		self.storage = storage
		self.serialized = serialize
	}
}
