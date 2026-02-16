//
//  CheckForKetonesStep.swift
//  xtod
//
//  Created by Zack Adlington on 06/02/2026.
//

import SwiftUI

struct CheckForKetonesStep: View {
    @State private var selectedKetones: Int = 15
    let onContinue: (Double) -> Void
    
    var body: some View {
        Form {
            Section("What's your current ketone level in mmol/L?") {
                Picker(
                    "Ketones",
                    selection: $selectedKetones
                ) {
                    ForEach(0...30, id: \.self) { step in
                        let value = Double(step) / 10.0
                        Text(String(format: "%.1f", value)).tag(step)
                    }
                }.pickerStyle(.wheel)
            }
        }
        .navigationTitle("Ketones")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Continue") {
                    onContinue(Double(selectedKetones) / 10.0)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CheckForKetonesStep(onContinue: { _ in })
    }
}
