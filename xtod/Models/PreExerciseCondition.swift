//
//  PreExerciseCondition.swift
//  xtod
//
//  Created by Zack Adlington on 03/02/2026.
//


struct PreExerciseCondition {
    var bgReadings: [BloodGlucoseReading]
    var ketoneReadings: [KetoneReading]
    var hypoInLast24Hours: Hypo?
    
    var mostRecentBGReading: BloodGlucoseReading? {
        get {
            return bgReadings.last
        }
        set {
            guard let newValue else { return }
            
            bgReadings.append(newValue)
        }
    }
    
    var mostRecentKetoneReading: KetoneReading? {
        get {
            return ketoneReadings.last
        }
        set {
            guard let newValue else { return }
            
            ketoneReadings.append(newValue)
        }
    }
}
