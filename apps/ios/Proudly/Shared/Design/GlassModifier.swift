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
  func proudlyGlass(cornerRadius: CGFloat = 22) -> some View {
    glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
  }
}
