//
//  PreExerciseWizard.swift
//  xtod
//
//  Created by Zack Adlington on 03/02/2026.
//

import SwiftUI
import Charts

private enum PreExerciseWizardStep: Hashable {
    case getBGFromAppleHealth
    case enterBGManually
    case checkForHypoRisk
}

struct PreExerciseWizardView: View {
    
    @State private var viewModel = PreExericseWizardViewModel()
    @State private var path: [PreExerciseWizardStep] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                ChooseBGSourceStep(
                    onChooseAppleHealth: {
                        print("Appending .getBGFromAppleHealth to path: ", path)
                        path.append(.getBGFromAppleHealth)
                        print("Path now: ", path)
                    },
                    onChooseManualEntry: { path.append(.enterBGManually) })
            }
            .padding()
            .navigationTitle("Blood glucose")
            .navigationDestination(for: PreExerciseWizardStep.self) { step in
                switch step {
                case .getBGFromAppleHealth:
                    GetBGFromAppleHealthStep(
                        viewModel: GetBGFromAppleHealthStepViewModel(),
                        onSuccess: { readings in
                            print("Appending .checkForHypoRisk to path: ", path)
                            path.append(.checkForHypoRisk)
                            print("Path now: ", path)
                        },
                        onFailure: { path.append(.enterBGManually) },
                    )
                case .enterBGManually:
                    Text("Todo!")
                case .checkForHypoRisk:
                    Text("Todo!")
                }
            }
        }
    }
}

#Preview("Choosing BG source") {
    PreExerciseWizardView()
}
