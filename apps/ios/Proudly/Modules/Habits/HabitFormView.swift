//
//  HabitFormView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftUI
import UIKit

private enum HabitReminderMode: String, CaseIterable, Identifiable {
  case none
  case basedOnTarget
  case customFirstTime

  var id: String { rawValue }

  var title: String {
    switch self {
    case .none:
      return "No reminder"
    case .basedOnTarget:
      return "Based on daily target"
    case .customFirstTime:
      return "Custom reminder times"
    }
  }

  var subtitle: String {
    switch self {
    case .none:
      return "Keep this habit quiet for now."
    case .basedOnTarget:
      return "Spread reminders gently through the day."
    case .customFirstTime:
      return "Pick each reminder time yourself."
    }
  }
}

struct HabitFormView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(ThemeViewModel.self) private var theme

  let habit: Habit?
  var onSave: (Habit) -> Void = { _ in }

  @State private var habitName: String
  @State private var habitDescription: String
  @State private var selectedIcon: String
  @State private var isSFSymbolPickerPresented = false
  @State private var selectedColorIndex: Int
  @State private var customColor: Color
  @State private var selectedTargetCount: Int
  @State private var customTargetCount: Int
  @State private var reminderMode: HabitReminderMode
  @State private var customReminderTimes: [Date]
  @State private var isSaving = false
  @State private var permissionMessage: String?
  @FocusState private var descriptionFocused: Bool

  private let icons = Self.iconOptions
  private let colors: [Color] = [
    ProudlyTheme.purple, ProudlyTheme.pink, ProudlyTheme.blue, ProudlyTheme.mint,
    .orange, .red, .yellow, .teal,
  ]

  init(habit: Habit? = nil, onSave: @escaping (Habit) -> Void = { _ in }) {
    self.habit = habit
    self.onSave = onSave

    let iconOptions = Self.iconOptions
    let colorOptions = Self.colorOptions

    let selectedIcon = {
      guard let icon = habit?.icon.trimmingCharacters(in: .whitespacesAndNewlines), !icon.isEmpty
      else {
        return iconOptions[0]
      }
      return icon
    }()

    let selectedColorIndex = Self.colorIndex(for: habit?.color, options: colorOptions)
    let fallbackColor = habit?.color ?? ProudlyTheme.purple
    let target = habit?.dailyTargetCount ?? 1
    let selectedTargetCount = (1...4).contains(target) ? target : 0
    let resolvedReminderMode = Self.resolveReminderMode(for: habit)
    let initialCustomReminderTimes = Self.resolveCustomReminderDates(
      for: habit, dailyTargetCount: target)

    _habitName = State(initialValue: habit?.name ?? "")
    _habitDescription = State(initialValue: habit?.note ?? "")
    _selectedIcon = State(initialValue: selectedIcon)
    _selectedColorIndex = State(initialValue: selectedColorIndex)
    _customColor = State(
      initialValue: selectedColorIndex == -1 ? fallbackColor : colorOptions[selectedColorIndex])
    _selectedTargetCount = State(initialValue: selectedTargetCount)
    _customTargetCount = State(initialValue: selectedTargetCount == 0 ? max(target, 4) : 5)
    _reminderMode = State(initialValue: resolvedReminderMode)
    _customReminderTimes = State(initialValue: initialCustomReminderTimes)
  }

  private static let iconOptions = [
    "drop.fill", "figure.walk", "book.fill", "moon.stars.fill", "heart.fill", "flame.fill",
    "sparkles", "pencil", "leaf.fill", "dumbbell.fill", "music.note", "fork.knife",
  ]
  private static let colorOptions: [Color] = [
    ProudlyTheme.purple, ProudlyTheme.pink, ProudlyTheme.blue, ProudlyTheme.mint,
    .orange, .red, .yellow, .teal,
  ]

  private var isEditing: Bool { habit != nil }
  private var isCustomIcon: Bool { !icons.contains(selectedIcon) }
  private var isCustomColor: Bool { selectedColorIndex == -1 }
  private var effectiveColor: Color { isCustomColor ? customColor : colors[selectedColorIndex] }
  private var effectiveDailyTargetCount: Int {
    selectedTargetCount == 0 ? max(customTargetCount, 4) : selectedTargetCount
  }
  private var effectiveIcon: String {
    if selectedIcon.isHabitSFSymbol {
      return selectedIcon
    }
    return selectedIcon.firstHabitEmoji ?? "sparkles"
  }
  private var canSave: Bool { !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
  private var reminderTimes: [String] {
    switch reminderMode {
    case .none:
      return []
    case .basedOnTarget:
      return NotificationManager.defaultReminderTimes(for: effectiveDailyTargetCount)
    case .customFirstTime:
      return normalizedCustomReminderTimes
    }
  }

  private var normalizedCustomReminderTimes: [String] {
    customReminderTimes
      .prefix(effectiveDailyTargetCount)
      .map(NotificationManager.timeString(from:))
  }

  private var showsReminderPicker: Bool {
    reminderMode == .customFirstTime
  }

  private var showsReminderPreview: Bool {
    reminderMode != .none && !reminderTimes.isEmpty
  }

  var body: some View {
    NavigationStack {
      ZStack {
        theme.activeTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
          LazyVStack(alignment: .leading, spacing: 28) {
            iconSection
            nameField
            descriptionField
            colorSection
            frequencySection
            reminderSection
          }
          .padding(.horizontal, 20)
          .padding(.top, 24)
          .padding(.bottom, 48)
        }
      }
      .navigationTitle(isEditing ? "Edit Habit" : "New Habit")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(isEditing ? "Save" : "Add") {
            Task {
              await saveHabit()
            }
          }
          .fontWeight(.semibold)
          .disabled(!canSave || isSaving)
        }
      }
      .tint(.primary)
      .alert(
        "Reminders unavailable", isPresented: .constant(permissionMessage != nil),
        actions: {
          Button("OK") { permissionMessage = nil }
        },
        message: {
          Text(permissionMessage ?? "")
        }
      )
      .sheet(isPresented: $isSFSymbolPickerPresented) {
        SFSymbolPickerView(
          selectedSymbol: $selectedIcon,
          symbolTint: effectiveColor,
          excludedSymbols: Set(icons)
        )
        .environment(theme)
      }
    }
    .preferredColorScheme(theme.activeTheme == .midnightCalm ? .dark : nil)
    .onChange(of: selectedTargetCount) { _, _ in
      synchronizeCustomReminderTimes()
    }
    .onChange(of: customTargetCount) { _, _ in
      synchronizeCustomReminderTimes()
    }
    .onChange(of: reminderMode) { _, newValue in
      guard newValue == .customFirstTime else { return }
      synchronizeCustomReminderTimes()
    }
  }

  private var iconSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Icon")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 10) {
          ForEach(icons.indices, id: \.self) { index in
            Button {
              selectedIcon = icons[index]
              Haptics.selection()
            } label: {
              iconBubble(
                icon: icons[index],
                isSelected: selectedIcon == icons[index]
              )
            }
            .buttonStyle(.plain)
          }

          pickerIconButton
        }
        .padding(.vertical, 2)
      }

      Text("Choose a preset, or open the full SF Symbol picker for more symbols and emoji.")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }

  private var nameField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Habit Name")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      TextField("Drink water", text: $habitName)
        .padding(14)
        .proudlyGlass(cornerRadius: 14)
    }
  }

  private var descriptionField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Description")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      TextField("What's your intention?", text: $habitDescription, axis: .vertical)
        .lineLimit(3, reservesSpace: true)
        .padding(14)
        .proudlyGlass(cornerRadius: 14)
        .focused($descriptionFocused)
        .toolbar {
          ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { descriptionFocused = false }
          }
        }
    }
  }

  private var colorSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Color")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 12) {
          ForEach(colors.indices, id: \.self) { index in
            Button {
              selectedColorIndex = index
              Haptics.selection()
            } label: {
              ZStack {
                Circle()
                  .fill(colors[index])
                  .frame(width: 34, height: 34)
                if selectedColorIndex == index {
                  Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                }
              }
              .animation(.spring(response: 0.25), value: selectedColorIndex)
            }
            .buttonStyle(.plain)
          }

          ZStack {
            ColorPicker("", selection: $customColor, supportsOpacity: false)
              .labelsHidden()
              .frame(width: 34, height: 34)
              .onChange(of: customColor) { _, _ in
                selectedColorIndex = -1
                Haptics.selection()
              }

            Circle()
              .fill(isCustomColor ? customColor : Color.gray.opacity(0.15))
              .frame(width: 34, height: 34)
              .overlay {
                if isCustomColor {
                  Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                } else {
                  Image(systemName: "plus")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.gray)
                }
              }
              .allowsHitTesting(false)
          }
          .frame(width: 34, height: 34)
          .clipShape(Circle())
          .animation(.spring(response: 0.25), value: isCustomColor)
        }
      }
    }
  }

  private var frequencySection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Daily Goal")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      VStack(spacing: 12) {
        ForEach([1, 2, 3, 4], id: \.self) { value in
          frequencyButton(value: value)
        }

        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("Custom")
              .font(.system(size: 16, weight: .semibold))
            Text("\(effectiveDailyTargetCount) times each day")
              .font(.caption)
              .foregroundStyle(.secondary)
              .contentTransition(.numericText())
          }

          Spacer()

          Stepper("", value: $customTargetCount, in: 4...8)
            .labelsHidden()
            .disabled(selectedTargetCount != 0)
            .opacity(selectedTargetCount == 0 ? 1 : 0.45)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(selectedTargetCount == 0 ? effectiveColor.opacity(0.16) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
        .proudlyGlass(cornerRadius: 16)
        .onTapGesture {
          selectedTargetCount = 0
          Haptics.selection()
        }
      }
    }
  }

  private var reminderSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Reminders")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      VStack(spacing: 12) {
        ForEach(HabitReminderMode.allCases) { mode in
          Button {
            reminderMode = mode
            Haptics.selection()
          } label: {
            HStack(spacing: 14) {
              Image(systemName: reminderIcon(for: mode))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(reminderMode == mode ? effectiveColor : .secondary)
                .frame(width: 22, height: 22)

              VStack(alignment: .leading, spacing: 4) {
                Text(mode.title)
                  .font(.system(size: 16, weight: .semibold))
                Text(mode.subtitle)
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }

              Spacer()

              Image(systemName: reminderMode == mode ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(reminderMode == mode ? effectiveColor : .secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(reminderMode == mode ? effectiveColor.opacity(0.16) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(Rectangle())
            .proudlyGlass(cornerRadius: 16)
          }
          .buttonStyle(.plain)
        }

        if showsReminderPicker || showsReminderPreview {
          VStack(alignment: .leading, spacing: 10) {
            if showsReminderPicker {
              VStack(alignment: .leading, spacing: 12) {
                ForEach(
                  Array(customReminderTimes.prefix(effectiveDailyTargetCount).indices), id: \.self
                ) { index in
                  DatePicker(
                    reminderPickerTitle(for: index),
                    selection: Binding(
                      get: { customReminderTimes[index] },
                      set: { updateCustomReminderTime(at: index, to: $0) }
                    ),
                    displayedComponents: .hourAndMinute
                  )
                  .datePickerStyle(.compact)
                }

                Text("Later reminders stay after the earlier ones.")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }

            if showsReminderPreview {
              VStack(alignment: .leading) {
                Text("Planned reminders")
                  .font(.caption.weight(.semibold))
                  .foregroundStyle(.secondary)

                Text(
                  NotificationManager.displayTimeStrings(from: reminderTimes)
                    .joined(separator: "  •  ")
                )
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
              }
              .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
          .padding(16)
          .proudlyGlass(cornerRadius: 16)
          .transition(.opacity.combined(with: .move(edge: .top)))
        }
      }
    }
    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: reminderMode)
  }

  private func frequencyButton(value: Int) -> some View {
    Button {
      selectedTargetCount = value
      Haptics.selection()
    } label: {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(value == 1 ? "Once a day" : value == 2 ? "Twice a day" : "\(value) times a day")
            .font(.system(size: 16, weight: .semibold))
          Text(value == 1 ? "A single daily check-in." : "Track a few gentle wins through the day.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        Spacer()
        Image(systemName: selectedTargetCount == value ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(selectedTargetCount == value ? effectiveColor : .secondary)
      }
      .padding(16)
      .frame(maxWidth: .infinity)
      .background(selectedTargetCount == value ? effectiveColor.opacity(0.16) : .clear)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .contentShape(Rectangle())
      .proudlyGlass(cornerRadius: 16)
    }
    .buttonStyle(.plain)
  }

  private var pickerIconButton: some View {
    Button {
      isSFSymbolPickerPresented = true
      Haptics.selection()
    } label: {
      ZStack {
        Circle()
          .fill(isCustomIcon ? effectiveColor : Color.gray.opacity(0.15))
          .frame(width: 52, height: 52)

        if isCustomIcon, let emoji = selectedIcon.firstHabitEmoji {
          Text(emoji)
            .font(.system(size: 26))
        } else if isCustomIcon {
          Image(systemName: selectedIcon)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
        } else {
          Image(systemName: "square.grid.2x2")
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(.gray)
        }
      }
      .animation(.spring(response: 0.25), value: selectedIcon)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(isCustomIcon ? "Edit selected custom icon" : "Open icon picker")
  }

  private func iconBubble(icon: String, isSelected: Bool) -> some View {
    ZStack {
      Circle()
        .fill(isSelected ? effectiveColor : effectiveColor.opacity(0.12))
        .frame(width: 52, height: 52)
      Image(systemName: icon)
        .font(.system(size: 20, weight: .semibold))
        .foregroundStyle(isSelected ? .white : effectiveColor)
    }
    .animation(.spring(response: 0.25), value: selectedIcon)
  }

  private func reminderIcon(for mode: HabitReminderMode) -> String {
    switch mode {
    case .none:
      return "bell.slash"
    case .basedOnTarget:
      return "bell.badge"
    case .customFirstTime:
      return "clock"
    }
  }

  private func reminderPickerTitle(for index: Int) -> String {
    let ordinalTitles = [
      "First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth",
    ]

    if index < ordinalTitles.count {
      return ordinalTitles[index] + " reminder"
    }

    return "Reminder \(index + 1)"
  }

  private func synchronizeCustomReminderTimes() {
    let count = max(effectiveDailyTargetCount, 1)

    if customReminderTimes.count > count {
      customReminderTimes = Array(customReminderTimes.prefix(count))
      return
    }

    if customReminderTimes.count < count {
      var updatedTimes = customReminderTimes
      while updatedTimes.count < count {
        updatedTimes.append(nextCustomReminderDate(after: updatedTimes.last))
      }
      customReminderTimes = updatedTimes
    }
  }

  private func updateCustomReminderTime(at index: Int, to newValue: Date) {
    guard customReminderTimes.indices.contains(index) else { return }

    var updatedTimes = customReminderTimes
    let minimumDate = minimumCustomReminderDate(for: index, in: updatedTimes)
    updatedTimes[index] = max(newValue, minimumDate)

    if index < updatedTimes.index(before: updatedTimes.endIndex) {
      for followingIndex in (index + 1)..<updatedTimes.count {
        let nextMinimumDate = minimumCustomReminderDate(for: followingIndex, in: updatedTimes)
        if updatedTimes[followingIndex] < nextMinimumDate {
          updatedTimes[followingIndex] = nextMinimumDate
        }
      }
    }

    customReminderTimes = updatedTimes
  }

  private func minimumCustomReminderDate(for index: Int, in times: [Date]) -> Date {
    guard index > 0, times.indices.contains(index - 1) else {
      return NotificationManager.reminderDate(from: "00:00")
    }

    return Calendar.current.date(byAdding: .minute, value: 1, to: times[index - 1])
      ?? times[index - 1]
  }

  private func nextCustomReminderDate(after previousDate: Date?) -> Date {
    let anchorDate = previousDate ?? NotificationManager.reminderDate(from: "09:00")
    return Calendar.current.date(byAdding: .hour, value: 1, to: anchorDate) ?? anchorDate
  }

  private static func resolveCustomReminderDates(for habit: Habit?, dailyTargetCount: Int) -> [Date]
  {
    let reminderDates = (habit?.reminderTimes ?? []).map(NotificationManager.reminderDate(from:))

    guard !reminderDates.isEmpty else {
      return defaultCustomReminderDates(for: dailyTargetCount)
    }

    let targetCount = max(dailyTargetCount, 1)
    if reminderDates.count >= targetCount {
      return Array(reminderDates.prefix(targetCount))
    }

    var updatedDates = reminderDates
    while updatedDates.count < targetCount {
      let anchorDate = updatedDates.last ?? NotificationManager.reminderDate(from: "09:00")
      updatedDates.append(
        Calendar.current.date(byAdding: .hour, value: 1, to: anchorDate) ?? anchorDate)
    }
    return updatedDates
  }

  private static func defaultCustomReminderDates(for dailyTargetCount: Int) -> [Date] {
    let targetCount = max(dailyTargetCount, 1)
    let startDate = NotificationManager.reminderDate(from: "09:00")

    return (0..<targetCount).compactMap { index in
      Calendar.current.date(byAdding: .hour, value: index, to: startDate)
    }
  }

  private func saveHabit() async {
    let remindersRequested = reminderMode != .none
    var remindersEnabled = false
    var savedReminderTimes: [String] = []

    if remindersRequested {
      let granted = await NotificationManager.shared.requestAuthorizationIfNeeded()
      if granted {
        remindersEnabled = true
        savedReminderTimes = reminderTimes
      } else {
        permissionMessage = "No worries. You can enable reminders later in Settings."
      }
    }

    isSaving = true

    let savedHabit = Habit(
      id: habit?.id ?? UUID(),
      name: habitName.trimmingCharacters(in: .whitespacesAndNewlines),
      icon: effectiveIcon,
      color: effectiveColor,
      streak: habit?.streak ?? 0,
      bestStreak: habit?.bestStreak ?? 0,
      completedDates: habit?.completedDates ?? [],
      completionCountsByDate: habit?.completionCountsByDate ?? [:],
      note: habitDescription.trimmingCharacters(in: .whitespacesAndNewlines),
      dailyTargetCount: effectiveDailyTargetCount,
      completedCountToday: habit?.completedCountToday ?? 0,
      remindersEnabled: remindersEnabled,
      reminderTimes: savedReminderTimes
    )

    onSave(savedHabit)
    isSaving = false
    dismiss()
  }

  private static func resolveReminderMode(for habit: Habit?) -> HabitReminderMode {
    guard let habit, habit.remindersEnabled else { return .none }

    let defaultTimes = NotificationManager.defaultReminderTimes(for: habit.dailyTargetCount)
    return habit.reminderTimes == defaultTimes ? .basedOnTarget : .customFirstTime
  }

  private static func colorIndex(for color: Color?, options: [Color]) -> Int {
    guard let color else { return 0 }
    guard let targetComponents = UIColor(color).rgbaComponents else { return -1 }

    for (index, option) in options.enumerated() {
      guard let optionComponents = UIColor(option).rgbaComponents else { continue }
      if optionComponents.isClose(to: targetComponents) {
        return index
      }
    }
    return -1
  }
}

private struct RGBAComponents {
  let red: CGFloat
  let green: CGFloat
  let blue: CGFloat
  let alpha: CGFloat

  func isClose(to other: RGBAComponents, tolerance: CGFloat = 0.01) -> Bool {
    abs(red - other.red) < tolerance && abs(green - other.green) < tolerance
      && abs(blue - other.blue) < tolerance && abs(alpha - other.alpha) < tolerance
  }
}

extension UIColor {
  fileprivate var rgbaComponents: RGBAComponents? {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
      return nil
    }
    return RGBAComponents(red: red, green: green, blue: blue, alpha: alpha)
  }
}

#Preview("New") {
  HabitFormView()
    .environment(ThemeViewModel())
}

#Preview("Edit") {
  HabitFormView(habit: Habit.samples[0])
    .environment(ThemeViewModel())
}
