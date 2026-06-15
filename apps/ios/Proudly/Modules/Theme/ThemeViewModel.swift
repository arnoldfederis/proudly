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
  static let plusCacheKey = "cachedHasProudlyPlus"
  private static let themeKey = "selectedAppTheme"

  var selectedTheme: ProudlyAppTheme
  var isPlusUser: Bool

  init() {
    let raw = UserDefaults.standard.string(forKey: Self.themeKey) ?? ""
    selectedTheme = ProudlyAppTheme(rawValue: raw) ?? .liquidGlass
    isPlusUser = UserDefaults.standard.bool(forKey: Self.plusCacheKey)
  }

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
    UserDefaults.standard.set(theme.rawValue, forKey: Self.themeKey)
    Haptics.selection()
  }
}
