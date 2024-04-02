//
//  XCTestCase.swift
//  
//
//  Created by Pat Nakajima on 4/2/24.
//

import XCTest

public extension XCTestCase {
	func XCTUnwrapAsync<T: Sendable>(_ expression: @autoclosure () async throws -> T?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) async throws -> T {

		let result = try await expression()

		return try await MainActor.run {
			return try XCTUnwrap(result)
		}
	}
}
