//
//  Log.swift
//  Wub2
//
//  Created by Pat Nakajima on 6/25/23.
//

import Foundation
import os

extension Data {
	func append(to fileURL: URL) throws {
		if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
			defer {
				fileHandle.closeFile()
			}
			fileHandle.seekToEndOfFile()
			fileHandle.write(self)
		} else {
			try write(to: fileURL, options: .atomic)
		}
	}
}

public enum LogLevel: String {
	case debug, info, error
}

extension Bundle {
		class var applicationName: String {

				if let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
						return displayName
				} else if let name: String = Bundle.main.infoDictionary?["CFBundleName"] as? String {
						return name
				}
				return "No Name Found"
		}
}

@available(iOS 16.0, *)
public enum Log {
	static var logger = Logger()
	static let localURL = URL.temporaryDirectory.appendingPathComponent("\(Bundle.applicationName).log")

	public static func debug(_ message: String) {
		logger.debug("\(message)")
		write(.debug, message: message)
	}

	public static func info(_ message: String) {
		logger.info("\(message)")
		write(.info, message: message)
	}

	public static func error(_ message: String) {
		logger.error("\(message)")
		write(.error, message: message)
	}

	@discardableResult public static func `catch`<T>(_ message: String? = nil, callback: @escaping () throws -> T?) -> T? {
		do {
			return try callback()
		} catch {
			Log.error((message ?? "Error") + ": \(error)")
			return nil
		}
	}

	@discardableResult public static func `catch`<T>(_ message: String, callback: @escaping () async throws -> T?) async -> T? {
		do {
			return try await callback()
		} catch {
			Log.error(message + ": \(error)")
			return nil
		}
	}

	public static func write(_ level: LogLevel, message: String) {
		do {
			let text = "\(level.rawValue.uppercased()) \(Date().ISO8601Format()) - \(message)\n"
			try Data(text.utf8).append(to: Log.localURL)
		} catch {
			logger.error("Could not write to file! \(error)")
		}
	}
}
