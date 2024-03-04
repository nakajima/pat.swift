//
//  TextThatFits.swift
//
//
//  Created by Pat Nakajima on 12/4/22.
//

import SwiftUI

public struct TextThatFits: View {
	var text: String
	var fonts: [Font]

	public init(_ text: String, fonts: [Font] = [.largeTitle, .title, .title2, .title3, .body, .subheadline, .caption, .caption2]) {
		self.text = text
		self.fonts = fonts
	}

	public var body: some View {
		ViewThatFits {
			ForEach(0 ..< fonts.count, id: \.self) { i in
				Text(text)
					.font(fonts[i])
			}
		}
	}
}
