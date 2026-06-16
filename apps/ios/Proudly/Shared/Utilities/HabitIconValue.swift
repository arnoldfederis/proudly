//
//  HabitIconValue.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/16/26.
//

import SwiftUI
import UIKit

extension String {
  var isHabitSFSymbol: Bool {
    UIImage(systemName: self) != nil
  }

  var firstHabitEmoji: String? {
    for character in self.trimmingCharacters(in: .whitespacesAndNewlines) {
      let scalars = character.unicodeScalars
      if scalars.contains(where: { $0.properties.isEmojiPresentation || $0.properties.isEmoji }) {
        return String(character)
      }
    }
    return nil
  }

  var isHabitEmoji: Bool {
    guard let firstHabitEmoji else { return false }
    return trimmingCharacters(in: .whitespacesAndNewlines) == firstHabitEmoji
  }
}
