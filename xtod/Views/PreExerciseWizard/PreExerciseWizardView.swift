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
    case checkForHypoRisk(readings: [BloodGlucoseReading])
    case checkHypoSeverity
    case checkForKetones
    case recommendExerciseCOA
}

struct PreExerciseWizardView: View {
    @State private var path: [PreExerciseWizardStep] = []
    @State var preExerciseCondition: PreExerciseCondition = PreExerciseCondition(bgReadings: [], ketoneReadings: [])
    
    var body: some View {
        NavigationStack(path: $path) {
            ChooseBGSourceStep(
                onChooseAppleHealth: {
                    path.append(.getBGFromAppleHealth)
                },
                onChooseManualEntry: {
                    path.append(.enterBGManually)
                }
            )
            .navigationTitle("Blood glucose")
            .navigationDestination(for: PreExerciseWizardStep.self) { step in
                switch step {
                case .getBGFromAppleHealth:
                    GetBGFromAppleHealthStep(
                        viewModel: GetBGFromAppleHealthStepViewModel(),
                        onSuccess: { readings in
                            preExerciseCondition.bgReadings = readings
                            
                            path.append(.checkForHypoRisk(readings: readings))
                        },
                        onFailure: {
                            path.append(.enterBGManually)
                        },
                    )
                case .enterBGManually:
                    EnterBGManuallyStep(
                        onContinue: { bgValue in
                            preExerciseCondition.bgReadings.append(
                                BloodGlucoseReading(timestamp: Date(), value: bgValue)
                            )
                            
                            if bgValue < 4.0 {
                                path.append(.recommendExerciseCOA)
                            }
                            
                            path.append(.checkForHypoRisk(readings: preExerciseCondition.bgReadings))
                        }
                    )
                case .checkForHypoRisk(let readings):
                    CheckForHypoRiskStep(
                        readings: readings,
                        onNoHypoLast24Hrs: {
                            if let reading = preExerciseCondition.mostRecentBGReading {
                                if reading.value > 15 {
                                    path.append(.checkForKetones)
                                } else {
                                    path.append(.recommendExerciseCOA)
                                }
                            }
                        },
                        onHypoLast24Hrs: {
                            path.append(.checkHypoSeverity)
                        },
                    )
                case .checkForKetones:
                    CheckForKetonesStep(
                        onContinue: { ketonesValue in
                            preExerciseCondition.mostRecentKetoneReading = KetoneReading(timestamp: Date(), value: ketonesValue)
                            path.append(.recommendExerciseCOA)
                        }
                    )
                case .recommendExerciseCOA:
                    RecommendExerciseCOAStep(preExerciseCondition: preExerciseCondition)
                case .checkHypoSeverity:
                    CheckHypoSeverityStep(
                        onSelfTreated: {
                            preExerciseCondition.hypoInLast24Hours = Hypo(requiredAssistance: false)
                            path.append(.recommendExerciseCOA)
                        },
                        onSevere: {
                            preExerciseCondition.hypoInLast24Hours = Hypo(requiredAssistance: true)
                            path.append(.recommendExerciseCOA)
                        }
                    )
                }
            }
        }
    }
    
    func recordHypoInLast24Hours(requiredAssistance: Bool, timestamp: Date?) -> Void {
        preExerciseCondition.hypoInLast24Hours = Hypo(
            requiredAssistance: requiredAssistance,
            timestamp: timestamp
        )
    }
}

#Preview {
    PreExerciseWizardView()
}
