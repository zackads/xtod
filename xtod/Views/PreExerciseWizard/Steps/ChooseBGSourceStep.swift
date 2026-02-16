//
//  AppleHealthPermissionStep.swift
//  xtod
//
//  Created by Zack Adlington on 04/02/2026.
//

import SwiftUI

struct ChooseBGSourceStep: View {
    @State private var bgFromAppleHealth: Bool = true
    let onChooseAppleHealth: () -> Void
    let onChooseManualEntry: () -> Void
    
    var body: some View {
        Form {
            Section("Where should your blood glucose readings come from?") {
                Picker(
                    "Blood glucose source",
                    selection: $bgFromAppleHealth
                ) {
                    Text("I'll enter my blood glucose manually").tag(false)
                    Text("Automatically get my blood glucsose from Apple Health").tag(true)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Continue") {
                    if bgFromAppleHealth {
                        onChooseAppleHealth()
                    } else {
                        onChooseManualEntry()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChooseBGSourceStep(onChooseAppleHealth: { }, onChooseManualEntry: { })
    }
}
