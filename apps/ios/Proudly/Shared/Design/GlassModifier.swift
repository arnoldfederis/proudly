//
//  GlassModifier.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/12/26.
//

import SwiftUI

extension View {
  /// Applies the standard Proudly Liquid Glass card style.
  /// Glass appearance (opacity, tint, blur) is governed by the system's
  /// Reduce Transparency / Increase Contrast accessibility settings.
  @ViewBuilder
  func proudlyGlass(cornerRadius: CGFloat = 22) -> some View {
    if #available(iOS 26.0, *) {
      glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
    } else {
      background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
  }
}
