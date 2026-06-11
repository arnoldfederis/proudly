//
//  ProfileViewModel.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import Foundation
import Observation

@Observable
final class ProfileViewModel {
  let isPlusUser: Bool = false
  var iCloudSyncEnabled: Bool = false
  var remindersEnabled: Bool = true
  var selectedTheme: String = "Liquid Glass"
}
