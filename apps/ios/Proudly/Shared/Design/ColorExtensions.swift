//
//  ColorExtensions.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/15/26.
//

import SwiftUI
import UIKit

extension Color {
  /// Initialise a Color from a 6-digit hex string, with or without a leading "#".
  init(hex: String) {
    var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if hex.hasPrefix("#") { hex.removeFirst() }
    var value: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&value)
    self.init(
      red: Double((value & 0xFF0000) >> 16) / 255,
      green: Double((value & 0x00FF00) >> 8) / 255,
      blue: Double(value & 0x0000FF) / 255
    )
  }

  /// Convert to a "#RRGGBB" hex string, resolved in the light trait environment
  /// so dynamic / adaptive colors produce a stable stored value.
  func toHex() -> String {
    let resolved = UIColor(self).resolvedColor(
      with: UITraitCollection(userInterfaceStyle: .light)
    )
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    resolved.getRed(&r, green: &g, blue: &b, alpha: &a)
    return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
  }
}
