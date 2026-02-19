//
//  ContentView.swift
//  xtod
//
//  Created by Zack Adlington on 27/01/2026.
//

import SwiftUI
import OpenAI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Learn", systemImage: "graduationcap") {
                ChatGoalView()
            }
            
            Tab("Plan", systemImage: "pencil") {
                PreExerciseWizardView()
            }
            
            Tab("Exercise", systemImage: "figure.run") {
                BluetoothDeviceManageView()
            }
            
            Tab("Recover", systemImage: "fuelpump") {
                Text("This is where after-exercise fuelling and insuling management will occur.")
            }
        }
    }
}

#Preview {
    ContentView()
}
