//
//  File.swift
//  
//
//  Created by Pat Nakajima on 4/7/24.
//

import Foundation
import OSLog

public struct DiskLogger {
	let logger: Logger
	public let location: URL

	enum LogType: String {
		case trace, debug, info, warning, error, fault, critical
	}

	public init(location: URL, subsystem: String = Bundle.main.bundleIdentifier!, category: String = "DiskLogger") {
		self.location = location
		self.logger = Logger(subsystem: subsystem, category: category)
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
			let text = "\(level.rawValue.uppercased()) \(Date().ISO8601Format()) - \(message)\n"
			try Data(text.utf8).append(to: location)
		} catch {

		}

		switch level {
		case .trace: 		logger.trace("\(message)")
		case .debug: 		logger.debug("\(message)")
		case .info: 		logger.info("\(message)")
		case .warning:	logger.warning("\(message)")
		case .error: 		logger.error("\(message)")
		case .fault:		logger.fault("\(message)")
		case .critical: logger.critical("\(message)")
		}
	}
}
