//
//  NewHabitView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftUI

struct NewHabitView: View {
  @Environment(\.dismiss) private var dismiss
  var onSave: () -> Void = {}

  @State private var habitName = ""
  @State private var habitDescription = ""
  @State private var selectedIconIndex = 0
  @State private var customEmoji = ""
  @State private var showEmojiInput = false
  @State private var selectedColorIndex = 0
  @State private var customColor = ProudlyTheme.purple
  @State private var dailyReminderEnabled = false
  @State private var reminderTime: Date = {
    var c = Calendar.current.dateComponents([.year, .month, .day], from: .now)
    c.hour = 9
    c.minute = 0
    return Calendar.current.date(from: c) ?? .now
  }()
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

  private var isCustomIcon: Bool { selectedIconIndex == -1 }
  private var isCustomColor: Bool { selectedColorIndex == -1 }
  private var effectiveColor: Color { isCustomColor ? customColor : colors[selectedColorIndex] }
  private var canSave: Bool { !habitName.trimmingCharacters(in: .whitespaces).isEmpty }

  var body: some View {
    NavigationStack {
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
      .background {
        ProudlyTheme.backgroundGradient.ignoresSafeArea()
      }
      .navigationTitle("New Habit")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Add") {
            dismiss()
            onSave()
          }
          .fontWeight(.semibold)
          .disabled(!canSave)
        }
      }
    }
  }

  // MARK: Icon

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

          // Custom emoji slot
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
            .onChange(of: customEmoji) { _, new in
              guard !new.isEmpty else { return }
              customEmoji = String(new.prefix(1))
              showEmojiInput = false
              emojiFieldFocused = false
            }
            .padding(12)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))

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

  // MARK: Name

  private var nameField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Habit Name")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      TextField("e.g. Drink water", text: $habitName)
        .padding(14)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
    }
  }

  // MARK: Description

  private var descriptionField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Description")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      TextField("What's your intention?", text: $habitDescription, axis: .vertical)
        .lineLimit(3, reservesSpace: true)
        .padding(14)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
    }
  }

  // MARK: Color

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

          // Custom color picker slot — overlay keeps our design, ColorPicker handles the tap
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

  // MARK: Daily Reminder

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
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: dailyReminderEnabled)
  }
}

#Preview {
  NewHabitView()
}
