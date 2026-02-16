//
//  CheckHypoSeverityStep.swift
//  xtod
//
//  Created by Zack Adlington on 11/02/2026.
//

import SwiftUI

struct CheckHypoSeverityStep: View {
    @State private var wasSevere = false
    
    let onSelfTreated: () -> Void
    let onSevere: () -> Void
    
    var body: some View {
        Form {
            Section("Did you require help from somebody else to manage your hypo?") {
                Picker(
                    "Hypo severity",
                    selection: $wasSevere
                ) {
                    Text("No").tag(false)
                    Text("Yes").tag(true)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Continue") {
                    if wasSevere {
                        onSevere()
                    } else {
                        onSelfTreated()
                    }
                }
            }
        }
        .navigationTitle("Hypo severity")
    }
}

#Preview {
    NavigationStack {
        CheckHypoSeverityStep(onSelfTreated: {}, onSevere: {})
    }
}
