//
//  SendableURLDelegate.swift
//
//
//  Created by Pat Nakajima on 4/24/24.
//

import Foundation

// To silence warnings about session delegates not being sendable, can pass this in.
public final class SendableURLSessionDelegate: NSObject, URLSessionDelegate, Sendable {
	override public init() { }
}
