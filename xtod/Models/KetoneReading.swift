//
//  KetoneReading.swift
//  xtod
//
//  Created by Zack Adlington on 03/02/2026.
//

import Foundation

struct KetoneReading: PointEvent {
    enum Unit {
        case mmolL
    }
    
    var timestamp: Date
    var value: Double
    var unit: Unit = .mmolL
}
