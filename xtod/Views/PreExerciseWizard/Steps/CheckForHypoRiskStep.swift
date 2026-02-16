//
//  CheckForHypoRiskStep.swift
//  xtod
//
//  Created by Zack Adlington on 07/02/2026.
//

import SwiftUI

struct CheckForHypoRiskStep: View {
    enum Showing: Hashable {
        case noReadings
        case readingsInconclusive
        case readingsNoHypo
        case readingsWithHypo
    }
    
    let readings: [BloodGlucoseReading]
    let onNoHypoLast24Hrs: () -> Void
    let onHypoLast24Hrs: () -> Void
    
    @State private var state: Showing
    @State private var hypoConfirmedInLast24Hrs: Bool = false
    private let hypoRiskAssessor = HypoRiskAssessor()
    
    init(
        readings: [BloodGlucoseReading],
        onNoHypoLast24Hrs: @escaping () -> Void,
        onHypoLast24Hrs: @escaping () -> Void
    )
    {
        self.readings = readings
        self.onNoHypoLast24Hrs = onNoHypoLast24Hrs
        self.onHypoLast24Hrs = onHypoLast24Hrs
        
        if readings.isEmpty {
            self.state = .noReadings
        } else {
            let hypoLast24Hrs: Bool? = hypoRiskAssessor.hadHypoInLast24Hours(readings: self.readings)
            
            switch hypoLast24Hrs {
            case nil:
                self.state = .readingsInconclusive
            case true:
                self.state = .readingsWithHypo
            case false:
                self.state = .readingsNoHypo
            }
        }
    }
    
    var body: some View {
        Group {
            switch state {
            case .noReadings:
                Form {
                    Section("No blood glucose data found.  Did you have a hypo in the last 24 hours?") {
                        Picker(
                            "Hypos last 24 hrs",
                            selection: $hypoConfirmedInLast24Hrs
                        ) {
                            Text("No").tag(false)
                            Text("Yes").tag(true)
                        }
                    }.pickerStyle(.segmented)
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Continue") {
                            if hypoConfirmedInLast24Hrs {
                                onHypoLast24Hrs()
                            } else {
                                onNoHypoLast24Hrs()
                            }
                        }
                    }
                }
            case .readingsInconclusive:
                Form {
                    Section("Did you have a hypo in the last 24 hours?") {
                        Picker(
                            "Hypos last 24 hrs",
                            selection: $hypoConfirmedInLast24Hrs
                        ) {
                            Text("No").tag(false)
                            Text("Yes").tag(true)
                        }
                    }.pickerStyle(.segmented)
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Continue") {
                            if hypoConfirmedInLast24Hrs {
                                onHypoLast24Hrs()
                            } else {
                                onNoHypoLast24Hrs()
                            }
                        }
                    }
                }
            case .readingsNoHypo:
                Form {
                    Section("It looks like you had no hypos in the last 24 hours.  Is this correct?") {
                        Picker(
                            "Hypos last 24 hrs",
                            selection: $hypoConfirmedInLast24Hrs
                        ) {
                            Text("No").tag(true)
                            Text("Yes").tag(false)
                        }
                    }.pickerStyle(.segmented)
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Continue") {
                            if hypoConfirmedInLast24Hrs {
                                onHypoLast24Hrs()
                            } else {
                                onNoHypoLast24Hrs()
                            }
                        }
                    }
                }
            case .readingsWithHypo:
                Form {
                    Section("Your blood glucose readings show you had a hypo in the last 24 hours.  Is this correct?") {
                        Picker(
                            "Hypo last 24 hrs",
                            selection: $hypoConfirmedInLast24Hrs
                        ) {
                            Text("No").tag(false)
                            Text("Yes").tag(true)
                        }
                    }.pickerStyle(.segmented)
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Continue") {
                            if hypoConfirmedInLast24Hrs {
                                onHypoLast24Hrs()
                            } else {
                                onNoHypoLast24Hrs()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Hypo risk")
    }
}

#Preview("No readings") {
    NavigationStack {
        CheckForHypoRiskStep(
            readings: [],
            onNoHypoLast24Hrs: { },
            onHypoLast24Hrs: { },
        )
    }
}

#Preview("No hypo in last 24 hours") {
    NavigationStack {
        CheckForHypoRiskStep(
            readings: [
                BloodGlucoseReading(
                    timestamp: Date().addingTimeInterval(-2 * 60 * 60),
                    value: 5.5
                ),
                BloodGlucoseReading(
                    timestamp: Date().addingTimeInterval(-6 * 60 * 60),
                    value: 5.6,
                )
            ],
            onNoHypoLast24Hrs: { },
            onHypoLast24Hrs: { },
        )
    }
}

#Preview("Hypo in last 24 hours") {
    NavigationStack {
        CheckForHypoRiskStep(
            readings: [
                BloodGlucoseReading(
                    timestamp: Date().addingTimeInterval(-2 * 60 * 60),
                    value: 3.2
                ),
                BloodGlucoseReading(
                    timestamp: Date().addingTimeInterval(-6 * 60 * 60),
                    value: 5.6,
                )
            ],
            onNoHypoLast24Hrs: { },
            onHypoLast24Hrs: { },
        )
    }
}
