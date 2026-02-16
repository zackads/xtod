//
//  BloodGlucoseReading.swift
//  xtod
//
//  Created by Zack Adlington on 03/02/2026.
//

import Foundation

struct BloodGlucoseReading: PointEvent, Hashable {
    enum Unit: String {
        case mmolL = "mmol/L"
    }
    
    var timestamp: Date
    var value: Double
    var unit: Unit = .mmolL
    
    var hypoglycaemic: Bool {
        unit == .mmolL && value < 4.0
    }
    
    init(value: Double) {
        self.timestamp = Date()
        self.unit = Unit.mmolL
        self.value = value
    }
    
    init(timestamp: Date, value: Double) {
        self.timestamp = timestamp
        self.unit = Unit.mmolL
        self.value = value
    }
}
