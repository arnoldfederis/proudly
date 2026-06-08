//
//  Haptics.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftUI

enum Haptics {
  static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
  }

  static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    UINotificationFeedbackGenerator().notificationOccurred(type)
  }

  static func selection() {
    UISelectionFeedbackGenerator().selectionChanged()
  }
}
