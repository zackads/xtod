//
//  AppleHealthPermissionStep.swift
//  xtod
//
//  Created by Zack Adlington on 04/02/2026.
//

import SwiftUI

struct ChooseBGSourceStep: View {
    let onChooseAppleHealth: () -> Void
    let onChooseManualEntry: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            Text("I need to know your current blood sugar so we can make recommendations about your training.")
            Text("I can check to see if your blood sugar exists in Apple Health, or you can enter it manually.")
            Text("What would you like to do?")
            
            Button {
                onChooseAppleHealth()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                    
                    Text("Automatically get my blood glucose from Apple Health")
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                onChooseManualEntry()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                    
                    Text("I'll enter my blood glucose manually")
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ChooseBGSourceStep(onChooseAppleHealth: { }, onChooseManualEntry: { })
}
