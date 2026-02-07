//
//  PreExerciseRecommendation.swift
//  xtod
//
//  Created by Zack Adlington on 03/02/2026.
//

import Foundation

protocol PreExerciseRecommendation {
    
}

struct ImmediateCarbRecommendation: PreExerciseRecommendation {
    enum Reason {
        case bgTooLow
    }
    var bgReading: BloodGlucoseReading
    var gramsCarbs: Int

    var reason: String {
        "If you start exercising now when your blood sugar is at \(bgReading.value)\(bgReading.unit) you are at risk of having a hypo. Take \(gramsCarbs)g of carbs."
    }
}

struct BeginAgainRecommendation: PreExerciseRecommendation {
    
}

struct WaitRecommendation: PreExerciseRecommendation {
    enum Reason {
        case severeHypo // Wait until 24 hours after last severe hypo
        case tooMuchInsulin // If user had meal with normal bolus insulin < 2 hours before, delay until two hours have passed
        case waitForCarbsToTakeEffect // BG is too low; take some carbs and wait.
    }
    
    var duration: TimeInterval
    var onCompletion: PreExerciseRecommendation
    var reason: Reason
    
    var explanation: String {
        switch self.reason {
        case .severeHypo:
            return "Wait \(Int(duration)) hours before exercising. This is to allow your body to recover from your last severe hypo."
        case .tooMuchInsulin:
            return "Wait \(Int(duration.rounded(.up))) hours before starting. This is to allow your body to recover from the last meal with normal bolus insulin."
        case .waitForCarbsToTakeEffect:
            return "Wait ("
        }
    }
}
