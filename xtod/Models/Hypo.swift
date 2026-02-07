//
//  Hypo.swift
//  xtod
//
//  Created by Zack Adlington on 03/02/2026.
//

import Foundation

struct Hypo: SpanEvent {

    var bgReadings: [BloodGlucoseReading]
    var requiredAssistance: Bool

    var wasSevere: Bool {
        get { requiredAssistance }
        set { requiredAssistance = newValue }
    }

    var start: Date {
        bgReadings.map(\.timestamp).min()!
    }

    var finish: Date {
        bgReadings.map(\.timestamp).max()!
    }

    init(
        bgReadings: [BloodGlucoseReading],
        requiredAssistance: Bool
    ) {
        precondition(!bgReadings.isEmpty, "Hypo must contain at least one BloodGlucoseReading")
        self.bgReadings = bgReadings
        self.requiredAssistance = requiredAssistance
    }
}
