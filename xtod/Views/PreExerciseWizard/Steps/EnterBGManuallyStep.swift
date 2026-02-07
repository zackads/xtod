//
//  EnterBloodGlucoseManuallyStep.swift
//  xtod
//
//  Created by Zack Adlington on 06/02/2026.
//

import SwiftUI

struct EnterBGManuallyStep: View {
    var body: some View {
        Text("TODO: Entering blood glucose manually")
        Form {
            Section("Current blood glucose (mmol/L)") {
                Picker(
                    "Blood glucose",
                    selection: Binding(
                        get: {
//                            if case let .enteringManualBloodGlucose(value) = viewModel.state {
//                                return value
//                            }
                            return 6.5
                        },
                        set: { newValue in
                            // viewModel.state = .enteringManualBloodGlucose(reading: newValue)
                        }
                    )
                ) {
                    ForEach(3...10, id: \.self) { value in
                        Text("\(value)")
                            .tag(value)
                    }
                }
            }
        }
    }
}
