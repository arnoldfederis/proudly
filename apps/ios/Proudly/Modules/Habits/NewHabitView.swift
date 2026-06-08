//
//  NewHabitView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import Foundation
import SwiftUI

struct NewHabitView: View {
  @Binding var isPresented: Bool
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("New Habit")
      Spacer()
      Button {
        isPresented = false
      } label: {
        Text("Add Habit")
          .font(.headline)
          .foregroundColor(.white)
          .padding()
          .frame(maxWidth: .infinity)
          .background(.accent)
          .cornerRadius(16)
      }
      .buttonStyle(.plain)
    }
    .padding(16)
    .navigationTitle("Add a new habit")
    .presentationDetents([.medium, .large])
    .presentationBackground(.regularMaterial)
  }
}

#Preview {
  @Previewable @State var isPresented = false
  NewHabitView(isPresented: $isPresented)
}
