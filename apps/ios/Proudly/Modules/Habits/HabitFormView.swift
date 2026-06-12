//
//  HabitFormView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftUI
import UIKit

struct HabitFormView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(ThemeViewModel.self) private var theme

  let habit: Habit?
  var onSave: (Habit) -> Void = { _ in }

  @State private var habitName: String
  @State private var habitDescription: String
  @State private var selectedIconIndex: Int
  @State private var customEmoji: String
  @State private var showEmojiInput = false
  @State private var selectedColorIndex: Int
  @State private var customColor: Color
  @State private var dailyReminderEnabled: Bool
  @State private var reminderTime: Date
  @FocusState private var emojiFieldFocused: Bool

  private let icons = [
    "star.fill", "heart.fill", "drop.fill", "figure.walk", "book.fill",
    "moon.fill", "sun.max.fill", "leaf.fill", "bolt.fill", "dumbbell.fill",
    "music.note", "fork.knife",
  ]
  private let colors: [Color] = [
    ProudlyTheme.purple, ProudlyTheme.pink, ProudlyTheme.blue, ProudlyTheme.mint,
    .orange, .red, .yellow, .teal,
  ]

  init(habit: Habit? = nil, onSave: @escaping (Habit) -> Void = { _ in }) {
    self.habit = habit
    self.onSave = onSave

    let iconOptions = Self.iconOptions
    let colorOptions = Self.colorOptions
    let seededReminderTime = Self.reminderDate(from: habit?.reminder)

    let selectedIconIndex: Int
    let customEmoji: String
    if let icon = habit?.icon, let index = iconOptions.firstIndex(of: icon) {
      selectedIconIndex = index
      customEmoji = ""
    } else if let icon = habit?.icon, !icon.isEmpty {
      selectedIconIndex = -1
      customEmoji = icon
    } else {
      selectedIconIndex = 0
      customEmoji = ""
    }

    let selectedColorIndex = Self.colorIndex(for: habit?.color, options: colorOptions)
    let fallbackColor = habit?.color ?? ProudlyTheme.purple

    _habitName = State(initialValue: habit?.name ?? "")
    _habitDescription = State(initialValue: habit?.note ?? "")
    _selectedIconIndex = State(initialValue: selectedIconIndex)
    _customEmoji = State(initialValue: customEmoji)
    _selectedColorIndex = State(initialValue: selectedColorIndex)
    _customColor = State(
      initialValue: selectedColorIndex == -1 ? fallbackColor : colorOptions[selectedColorIndex])
    _dailyReminderEnabled = State(initialValue: habit?.reminder != nil)
    _reminderTime = State(initialValue: seededReminderTime)
  }

  private static let iconOptions = [
    "star.fill", "heart.fill", "drop.fill", "figure.walk", "book.fill",
    "moon.fill", "sun.max.fill", "leaf.fill", "bolt.fill", "dumbbell.fill",
    "music.note", "fork.knife",
  ]
  private static let colorOptions: [Color] = [
    ProudlyTheme.purple, ProudlyTheme.pink, ProudlyTheme.blue, ProudlyTheme.mint,
    .orange, .red, .yellow, .teal,
  ]

  private var isEditing: Bool { habit != nil }
  private var isCustomIcon: Bool { selectedIconIndex == -1 }
  private var isCustomColor: Bool { selectedColorIndex == -1 }
  private var effectiveColor: Color { isCustomColor ? customColor : colors[selectedColorIndex] }
  private var effectiveIcon: String {
    if isCustomIcon {
      return customEmoji.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? "star.fill" : customEmoji
    }
    return icons[selectedIconIndex]
  }
  private var canSave: Bool { !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

  var body: some View {
    NavigationStack {
      ZStack {
        theme.activeTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
          VStack(alignment: .leading, spacing: 28) {
            iconSection
            nameField
            descriptionField
            colorSection
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
          Button("Cancel") {
            dismiss()
          }
          //          .tint(effectiveColor)
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(isEditing ? "Save" : "Add") {
            saveHabit()
          }
          //          .tint(effectiveColor)
          .fontWeight(.semibold)
          .disabled(!canSave)
        }
      }
      .tint(.primary)
    }
    .preferredColorScheme(theme.activeTheme == .midnightCalm ? .dark : nil)
  }

  private var iconSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Icon")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(icons.indices, id: \.self) { i in
            Button {
              selectedIconIndex = i
              showEmojiInput = false
              Haptics.selection()
            } label: {
              ZStack {
                Circle()
                  .fill(selectedIconIndex == i ? effectiveColor : effectiveColor.opacity(0.12))
                  .frame(width: 52, height: 52)
                Image(systemName: icons[i])
                  .font(.system(size: 20))
                  .foregroundStyle(selectedIconIndex == i ? .white : effectiveColor)
              }
              .animation(.spring(response: 0.25), value: selectedIconIndex)
            }
            .buttonStyle(.plain)
          }

          Button {
            selectedIconIndex = -1
            showEmojiInput = true
            emojiFieldFocused = true
            Haptics.selection()
          } label: {
            ZStack {
              Circle()
                .fill(
                  isCustomIcon && !customEmoji.isEmpty ? effectiveColor : Color.gray.opacity(0.15)
                )
                .frame(width: 52, height: 52)
              if isCustomIcon && !customEmoji.isEmpty {
                Text(customEmoji)
                  .font(.system(size: 26))
              } else {
                Image(systemName: "plus")
                  .font(.system(size: 18, weight: .medium))
                  .foregroundStyle(.gray)
              }
            }
            .animation(.spring(response: 0.25), value: isCustomIcon && !customEmoji.isEmpty)
          }
          .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
      }

      if showEmojiInput {
        HStack(spacing: 10) {
          TextField("Type an emoji…", text: $customEmoji)
            .focused($emojiFieldFocused)
            .onChange(of: customEmoji) { _, newValue in
              let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
              guard !trimmed.isEmpty else { return }
              customEmoji = String(trimmed.prefix(1))
              showEmojiInput = false
              emojiFieldFocused = false
            }
            .padding(12)
            .proudlyGlass(cornerRadius: 12)

          Button("Cancel") {
            showEmojiInput = false
            if customEmoji.isEmpty { selectedIconIndex = 0 }
          }
          .foregroundStyle(.secondary)
          .buttonStyle(.plain)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showEmojiInput)
  }

  private var nameField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Habit Name")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      TextField("e.g. Drink water", text: $habitName)
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
    }
  }

  private var colorSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Color")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(colors.indices, id: \.self) { i in
            Button {
              selectedColorIndex = i
              Haptics.selection()
            } label: {
              ZStack {
                Circle()
                  .fill(colors[i])
                  .frame(width: 34, height: 34)
                if selectedColorIndex == i {
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

  private var reminderSection: some View {
    VStack(spacing: 0) {
      HStack {
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(ProudlyTheme.purple.opacity(0.15))
            .frame(width: 34, height: 34)
          Image(systemName: "bell.fill")
            .font(.system(size: 14))
            .foregroundStyle(ProudlyTheme.purple)
        }
        Text("Daily Reminder").font(.system(size: 16, weight: .medium))
        Spacer()
        Toggle("", isOn: $dailyReminderEnabled).labelsHidden()
      }
      .padding(16)

      if dailyReminderEnabled {
        Divider()
          .padding(.leading, 62)
          .opacity(0.4)

        HStack {
          Text("Time")
            .font(.system(size: 15))
            .foregroundStyle(.secondary)
          Spacer()
          DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
      }
    }
    .proudlyGlass(cornerRadius: 16)
    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: dailyReminderEnabled)
  }

  private func saveHabit() {
    let savedHabit = Habit(
      id: habit?.id ?? UUID(),
      name: habitName.trimmingCharacters(in: .whitespacesAndNewlines),
      icon: effectiveIcon,
      color: effectiveColor,
      streak: habit?.streak ?? 0,
      bestStreak: habit?.bestStreak ?? 0,
      completedDates: habit?.completedDates ?? [],
      note: habitDescription.trimmingCharacters(in: .whitespacesAndNewlines),
      reminder: dailyReminderEnabled ? Self.reminderString(from: reminderTime) : nil
    )
    onSave(savedHabit)
    dismiss()
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

  private static func reminderDate(from reminder: String?) -> Date {
    guard let reminder else { return defaultReminderDate }
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    return formatter.date(from: reminder) ?? defaultReminderDate
  }

  private static func reminderString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    return formatter.string(from: date)
  }

  private static var defaultReminderDate: Date {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
    components.hour = 9
    components.minute = 0
    return Calendar.current.date(from: components) ?? .now
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
