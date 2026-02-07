//
//  Meal.swift
//  xtod
//
//  Created by Zack Adlington on 03/02/2026.
//

import Foundation

protocol Food: PointEvent {
    var carbsGrams: Int  { get set }
    var bolus: InsulinDose?  { get set }
}

struct Meal: Food {
    var timestamp: Date
    var carbsGrams: Int
    var bolus: InsulinDose?
}

struct Snack: Food {
    var timestamp: Date
    var carbsGrams: Int
    var bolus: InsulinDose?
}
