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
    var unit: Unit
    var value: Float
}
