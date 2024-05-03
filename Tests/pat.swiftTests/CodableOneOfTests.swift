import pat_swift
import XCTest

struct TestPostOne: Encodable {
	var author: String?
}

struct TestPostMany: Encodable {
	var author: [String]
}

struct TestPost: Decodable {
	var author: SomeDecodable<String>?
}

final class CodableOneOfTests: XCTestCase {
	func testNone() throws {
		let noneData = try JSONEncoder().encode(TestPostOne(author: nil))
		let none = try JSONDecoder().decode(TestPost.self, from: noneData)
		XCTAssertEqual(nil, none.author)
	}

	func testOne() throws {
		let oneData = try JSONEncoder().encode(TestPostOne(author: "Pat"))
		let one = try JSONDecoder().decode(TestPost.self, from: oneData)
		XCTAssertEqual(.one("Pat"), one.author)
	}

	func testMany() throws {
		let manyData = try JSONEncoder().encode(TestPostMany(author: ["Pat"]))
		let many = try JSONDecoder().decode(TestPost.self, from: manyData)
		XCTAssertEqual(.many(["Pat"]), many.author)
	}
}
