//
//  DiskLogger.swift
//
//
//  Created by Pat Nakajima on 4/7/24.
//

import Foundation
import OSLog

private class Truncator {
	static func truncate(at url: URL, toLineCount lineCount: Int) throws {
		guard let reader = Truncator(url: url) else {
			return
		}

		// Use a buffer to keep the last `lineCount` lines
		var buffer = [String]()
		buffer.reserveCapacity(lineCount)

		// Read each line and maintain only the last `lineCount` lines in the buffer
		for line in reader {
			if buffer.count >= lineCount {
				buffer.removeFirst()
			}
			buffer.append(line)
		}

		// Write the contents of buffer to the file
		let newContents = buffer.joined(separator: "\n")
		try newContents.write(to: url, atomically: true, encoding: .utf8)
	}

	let fileHandle: FileHandle
	let bufferLength: Int
	var buffer: Data

	init?(url: URL, bufferLength: Int = 4096) {
		guard let handle = try? FileHandle(forReadingFrom: url) else { return nil }
		self.fileHandle = handle
		self.bufferLength = bufferLength
		self.buffer = Data(capacity: bufferLength)
	}

	deinit {
		fileHandle.closeFile()
	}

	func nextLine() -> String? {
		// Keep reading until a newline character is found
		while true {
			if let range = buffer.range(of: Data([0x0A]), options: [], in: buffer.startIndex ..< buffer.endIndex) {
				// Extract the line
				let line = String(data: buffer.subdata(in: buffer.startIndex ..< range.lowerBound), encoding: .utf8)
				buffer.removeSubrange(buffer.startIndex ... range.lowerBound)
				return line
			}
			let tempData = fileHandle.readData(ofLength: bufferLength)
			if tempData.isEmpty {
				return nil
			}
			buffer.append(tempData)
		}
	}
}

extension Truncator: Sequence {
	func makeIterator() -> AnyIterator<String> {
		return AnyIterator {
			self.nextLine()
		}
	}
}

@MainActor public struct DiskLogger: Sendable {
	public let location: URL
	public let maxLines: Int

	public enum LogType: String, Sendable {
		case trace, debug, info, warning, error, fault, critical
	}

	public struct Entry: Sendable {
		static let formatter = ISO8601DateFormatter()

		public let timestamp: Date
		public let level: LogType
		public let text: String

		init?(string: String) {
			let parts = string.split(separator: "\t", maxSplits: 3).map { String($0) }

			guard parts.count == 3,
			      let level = LogType(rawValue: parts[0].lowercased()),
			      let timestamp = Entry.formatter.date(from: parts[1])
			else {
				return nil
			}

			self.level = level
			self.timestamp = timestamp
			self.text = parts[2]
		}
	}

	var entries: [Entry] = []

	public mutating func truncate() throws {
		try Truncator.truncate(at: location, toLineCount: maxLines)
	}

	public mutating func clear() throws {
		try FileManager.default.removeItem(at: location)
		entries = []
	}

	public mutating func load() {
		if let entries = try? String(contentsOf: location, encoding: .utf8).split(separator: "\n").compactMap({ Entry(string: String($0)) }) {
			self.entries = entries
		}
	}

	public init(location: URL, maxLines: Int = 1024) {
		self.location = location
		self.maxLines = maxLines

		#if DEBUG
			try? truncate()
		#endif
	}

	public func trace(_ message: String) {
		write(.trace, message)
	}

	public func warning(_ message: String) {
		write(.warning, message)
	}

	public func info(_ message: String) {
		write(.info, message)
	}

	public func debug(_ message: String) {
		write(.debug, message)
	}

	public func error(_ message: String) {
		write(.error, message)
	}

	public func fault(_ message: String) {
		write(.fault, message)
	}

	public func critical(_ message: String) {
		write(.critical, message)
	}

	func write(_ level: LogType, _ message: String) {
		#if DEBUG
			do {
				let text = "\(level.rawValue.uppercased())\t\(Date().ISO8601Format())\t\(message)\n"
				try Data(text.utf8).append(to: location)
			} catch {}
		#endif

		switch level {
		case .trace, .debug:
			os_log(.debug, "\(message)")
		case .info:
			os_log(.info, "\(message)")
		case .warning, .error:
			os_log(.error, "\(message)")
		case .fault, .critical:
			os_log(.fault, "\(message)")
		}
	}
}

#if DEBUG
	extension DiskLogger {
		static let preview = DiskLogger(location: URL.temporaryDirectory.appending(path: "logs.log"))
	}
#endif
