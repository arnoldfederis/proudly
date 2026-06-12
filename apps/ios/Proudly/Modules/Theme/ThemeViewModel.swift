//
//  ThemeViewModel.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/12/26.
//

import Foundation
import Observation

@Observable
final class ThemeViewModel {
  var selectedTheme: ProudlyAppTheme = .liquidGlass
  var isPlusUser: Bool = false

  var activeTheme: ProudlyAppTheme {
    if selectedTheme.isPlusOnly && !isPlusUser {
      return .liquidGlass
    }
    return selectedTheme
  }

  func canUse(_ theme: ProudlyAppTheme) -> Bool {
    !theme.isPlusOnly || isPlusUser
  }

  func select(_ theme: ProudlyAppTheme) {
    guard canUse(theme) else { return }
    selectedTheme = theme
    Haptics.selection()
  }
}
