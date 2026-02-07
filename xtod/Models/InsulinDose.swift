//
//  PreExerciseConditions.swift
//  xtod
//
//  Created by Zack Adlington on 03/02/2026.
//

import Foundation

protocol InsulinDose: PointEvent {
    var quantity: Float { get set }
}

struct BasalInsulinDose: PointEvent {
    var timestamp: Date
    var quantity: Float
}

struct BolusInsulinDose: PointEvent {
    var timestamp: Date
    var quantity: Float
}

struct CorrectionInsulinDose: PointEvent {
    var timestamp: Date
    var quantity: Float
}

