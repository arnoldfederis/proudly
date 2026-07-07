//
//  CloudKitSyncMonitor.swift
//  Proudly
//

import CloudKit
import CoreData
import Foundation
import SwiftUI

@MainActor
@Observable
final class CloudKitSyncMonitor {
  enum Status: Equatable {
    case unknown
    case localOnly
    case signedOut
    case unavailable
    case idle
    case syncing
    case error(String)
  }

  private(set) var status: Status = .unknown
  private(set) var lastSyncedAt: Date?
  private(set) var accountStatus: CKAccountStatus = .couldNotDetermine

  private var eventObserver: NSObjectProtocol?
  private var accountObserver: NSObjectProtocol?
  private var cloudKitEnabled: Bool

  init(cloudKitEnabled: Bool = true) {
    self.cloudKitEnabled = cloudKitEnabled
    if !cloudKitEnabled {
      self.status = .localOnly
    }
  }

  func start() async {
    guard cloudKitEnabled else {
      status = .localOnly
      return
    }
    await refreshAccountStatus()
    subscribeToEvents()
    subscribeToAccountChanges()
  }

  func refreshAccountStatus() async {
    do {
      let currentStatus = try await CKContainer.default().accountStatus()
      self.accountStatus = currentStatus
      updateStatusForAccount(currentStatus)
    } catch {
      self.accountStatus = .couldNotDetermine
      self.status = .error(error.localizedDescription)
    }
  }

  private func updateStatusForAccount(_ account: CKAccountStatus) {
    guard cloudKitEnabled else {
      status = .localOnly
      return
    }
    switch account {
    case .available:
      if case .syncing = status { return }
      if case .error = status { return }
      status = .idle
    case .noAccount:
      status = .signedOut
    case .restricted, .temporarilyUnavailable:
      status = .unavailable
    case .couldNotDetermine:
      status = .unknown
    @unknown default:
      status = .unknown
    }
  }

  private func subscribeToEvents() {
    guard eventObserver == nil else { return }
    eventObserver = NotificationCenter.default.addObserver(
      forName: NSPersistentCloudKitContainer.eventChangedNotification,
      object: nil,
      queue: .main
    ) { [weak self] note in
      guard let self else { return }
      let userInfo = note.userInfo
      Task { @MainActor in
        self.handleEvent(userInfo: userInfo)
      }
    }
  }

  private func handleEvent(userInfo: [AnyHashable: Any]?) {
    guard
      let event = userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
        as? NSPersistentCloudKitContainer.Event
    else { return }
    if event.endDate == nil {
      status = .syncing
      return
    }
    if let error = event.error {
      status = .error(error.localizedDescription)
      return
    }
    lastSyncedAt = event.endDate
    if accountStatus == .available {
      status = .idle
    }
  }

  private func subscribeToAccountChanges() {
    guard accountObserver == nil else { return }
    accountObserver = NotificationCenter.default.addObserver(
      forName: .CKAccountChanged,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        await self?.refreshAccountStatus()
      }
    }
  }

}
