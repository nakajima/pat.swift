//
//  UserDefault.swift
//
//
//  Created by Pat Nakajima on 4/20/24.
//

import Foundation

@propertyWrapper struct UserDefault<Value: Codable> {
	var wrappedValue: Value {
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

	init(
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
