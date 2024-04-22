//
//  Haptics.swift
//  Haptics
//
//  Created by Pat Nakajima on 7/24/21.
//

import CoreHaptics
import Foundation

struct HapticPattern {
	struct Event {
		var intensity: Float
		var sharpness: Float
		var relativeTime: TimeInterval
	}

	var events: [Event] = []

	mutating func add(intensity: Float, sharpness: Float, relativeTime: TimeInterval) {
		events.append(Event(intensity: intensity, sharpness: sharpness, relativeTime: relativeTime))
	}

	func play(engine: CHHapticEngine?) {
		guard let engine = engine else {
			return
		}

		do {
			try engine.start()
		} catch {
			print("Could not start haptic engine \(error)")
		}

		var hapticEvents = [CHHapticEvent]()
		for event in events {
			let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: event.intensity)
			let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: event.sharpness)
			let hapticEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: event.relativeTime)
			hapticEvents.append(hapticEvent)
		}

		do {
			let pattern = try CHHapticPattern(events: hapticEvents, parameters: [])
			let player = try engine.makePlayer(with: pattern)
			try player.start(atTime: 0)
		} catch {
			print("Failed to play pattern: \(error.localizedDescription).")
		}
	}
}

public struct Haptics {
	let engine: CHHapticEngine?

	public static let shared = Haptics()
	public init() {
		// swiftlint:disable no_optional_try
		self.engine = try? CHHapticEngine()
		// swiftlint:enable no_optional_try
		do {
			try engine?.start()
		} catch {
			print("Could not start haptic engine \(error)!")
		}
	}

	public func click() {
		var pattern = HapticPattern()
		pattern.add(intensity: 1, sharpness: 1, relativeTime: 0)
		pattern.play(engine: engine)
	}

	public func collide() {
		var pattern = HapticPattern()
		pattern.add(intensity: 0.2, sharpness: 1, relativeTime: 0)
		pattern.play(engine: engine)
	}

	public func win() {
		var pattern = HapticPattern()
		pattern.add(intensity: 1, sharpness: 1, relativeTime: 0)
		pattern.add(intensity: 1, sharpness: 1, relativeTime: 0.25)
		pattern.play(engine: engine)
	}

	public func loss() {
		var pattern = HapticPattern()
		pattern.add(intensity: 1, sharpness: 1, relativeTime: 0)
		pattern.add(intensity: 1, sharpness: 0.1, relativeTime: 0.25)
		pattern.play(engine: engine)
	}

	public func tie() {
		var pattern = HapticPattern()
		pattern.add(intensity: 0.2, sharpness: 1, relativeTime: 0)
		pattern.add(intensity: 0.4, sharpness: 1, relativeTime: 0.03)
		pattern.add(intensity: 0.8, sharpness: 1, relativeTime: 0.03)
		pattern.add(intensity: 1, sharpness: 0, relativeTime: 0.03)
		pattern.play(engine: engine)
	}

	public func deal() {
		var pattern = HapticPattern()
		pattern.add(intensity: 1, sharpness: 1, relativeTime: 0)
		pattern.add(intensity: 0.6, sharpness: 1, relativeTime: 0.125)
		pattern.add(intensity: 1, sharpness: 1, relativeTime: 0.125)
		pattern.play(engine: engine)
	}

	public func doubleDown() {
		var pattern = HapticPattern()
		pattern.add(intensity: 1, sharpness: 0.3, relativeTime: 0)
		pattern.add(intensity: 1, sharpness: 0.5, relativeTime: 0.25)
		pattern.play(engine: engine)
	}

	public func split() {
		var pattern = HapticPattern()
		pattern.add(intensity: 1, sharpness: 1, relativeTime: 0)
		pattern.add(intensity: 1, sharpness: 1, relativeTime: 0.125)
		pattern.add(intensity: 1, sharpness: 1, relativeTime: 0.125)
		pattern.play(engine: engine)
	}
}
