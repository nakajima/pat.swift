//
//  File.swift
//  
//
//  Created by Pat Nakajima on 4/7/24.
//

import Foundation
import OSLog

@Observable public final class DiskLogger: Sendable {
	public let location: URL

	public enum LogType: String {
		case trace, debug, info, warning, error, fault, critical
	}

	public struct Entry {
		static let formatter = ISO8601DateFormatter()

		public let timestamp: Date
		public let level: LogType
		public let text: String

		init?(string: String) {
			let parts = string.split(separator: "\t", maxSplits: 3).map { String($0) }

			guard parts.count == 3,
				let level = LogType(rawValue: parts[0].lowercased()),
				let timestamp = Entry.formatter.date(from: parts[1]) else {
				return nil
			}

			self.level = level
			self.timestamp = timestamp
			self.text = parts[2]
		}
	}

	var entries: [Entry] = []

	public func clear() throws {
		try FileManager.default.removeItem(at: location)
		self.entries = []
	}

	public func load() {
		if let entries = try? String(contentsOf: location, encoding: .utf8).split(separator: "\n").compactMap({ Entry(string: String($0)) }) {
			self.entries = entries
		}
	}

	public init(location: URL, subsystem: String = Bundle.main.bundleIdentifier!, category: String = "DiskLogger") {
		self.location = location
//		self.logger = Logger(subsystem: subsystem, category: category)
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
		do {
			let text = "\(level.rawValue.uppercased())\t\(Date().ISO8601Format())\t\(message)\n"
			try Data(text.utf8).append(to: location)
		} catch {

		}

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
	static let preview = {
		DiskLogger(location: URL.temporaryDirectory.appending(path: "logs.log"))
	}()
}
#endif
