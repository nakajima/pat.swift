//
//  SomeDecodable.swift
//  
//
//  Created by Pat Nakajima on 5/3/24.
//

import Foundation

public enum SomeDecodable<T: Decodable>: Decodable {
	case none, one(T), many([T])

	public init(from decoder: any Decoder) throws {
		let container = try! decoder.singleValueContainer()

		if let one = try? container.decode(T.self) {
			self = .one(one)
		} else if let many = try? container.decode([T].self) {
			self = .many(many)
		} else {
			self = .none
		}
	}
}

extension SomeDecodable: Equatable where T: Equatable { }
