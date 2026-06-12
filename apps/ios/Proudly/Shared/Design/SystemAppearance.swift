//
//  SystemAppearance.swift
//  Proudly
//
//  Created by Codex on 6/12/26.
//

import SwiftUI
import UIKit

enum SystemAppearance {
  static var colorScheme: ColorScheme {
    switch UIScreen.main.traitCollection.userInterfaceStyle {
    case .dark:
      return .dark
    default:
      return .light
    }
  }
}
