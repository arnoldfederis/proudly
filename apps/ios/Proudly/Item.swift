//
//  Item.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import Foundation
import SwiftData

@Model
final class Item {
  var timestamp: Date

  init(timestamp: Date) {
    self.timestamp = timestamp
  }
}
