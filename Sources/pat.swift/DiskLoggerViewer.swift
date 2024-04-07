//
//  File.swift
//  
//
//  Created by Pat Nakajima on 4/7/24.
//

#if canImport(SwiftUI)
import Foundation
import SwiftUI

public struct DiskLoggerViewer: View {
	var logger: DiskLogger

	public init(logger: DiskLogger) {
		self.logger = logger
	}

	public var body: some View {
		if let entries = logger.entries {
			List {
				ForEach(entries, id: \.timestamp) { entry in
					VStack(alignment: .leading, spacing: 4) {
						Text(entry.text)
							.padding(2)
						HStack(alignment: .firstTextBaseline) {
							Text(entry.level.rawValue.uppercased())
								.padding(2)
								.padding(.horizontal, 4)
								.background(.ultraThinMaterial)
								.clipShape(RoundedRectangle(cornerRadius: 4))
								.font(.caption2)
							Text(entry.timestamp.formatted(date: .numeric, time: .standard))
						}
					}
					.listRowInsets(.init(top: 8, leading: 12, bottom: 8, trailing: 4))
				}
				.font(.caption)
			}
			.fontDesign(.monospaced)
		} else {
			Text("No logs found.")
		}
	}
}

#if DEBUG
#Preview {
	DiskLoggerViewer(logger: DiskLogger.preview)
		.onAppear {
			DiskLogger.preview.info("oh hi")
			DiskLogger.preview.trace("sup")
			DiskLogger.preview.debug("neato")
		}
}
#endif
#endif
