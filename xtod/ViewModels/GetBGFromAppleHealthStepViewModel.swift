//
//  HealthDataViewModel.swift
//  xtod
//
//  Created by Zack Adlington on 04/02/2026.
//

import Foundation
import HealthKit
import Observation

@MainActor
@Observable
class GetBGFromAppleHealthStepViewModel {
    enum State: Hashable {
        case requestingHKAuthorization
        case deniedHKAuthorization
        case HKAuthorizedFetchingData
        case HKAuthorizedButNoData
        case HKAuthorizedButStaleData
        case HKAuthorizedWithCurrentData
        case error(errorMessage: String)
    }
    
    var state: State = .requestingHKAuthorization
    var readings: [BloodGlucoseReading] = []
    var mostRecentReading: BloodGlucoseReading? {
        readings.last
    }
    
    init() {
        
    }
    
    func requestAuthorization() async {
        do {
            state = .requestingHKAuthorization
            
            let authorized = try await HealthKitManager.shared.requestAuthorization()
            
            if !authorized {
                state = .deniedHKAuthorization
            } else {
                state = .HKAuthorizedFetchingData
                
                readings = await fetchLast24HrsBloodGlucose()
                
                if readings.isEmpty {
                    state = .HKAuthorizedButNoData
                } else if let lastReading = readings.last, lastReading.timestamp < Date().addingTimeInterval(-15 * 60) {
                    state = .HKAuthorizedButStaleData
                    readings = readings
                } else {
                    state = .HKAuthorizedWithCurrentData
                    readings = readings
                }
            }
        } catch {
            state = .error(errorMessage: error.localizedDescription)
        }
    }
    
func fetchLast24HrsBloodGlucose() async -> [BloodGlucoseReading] {
    let bloodGlucoseMMolLUnit = HKUnit.moleUnit(with: .milli, molarMass: HKUnitMolarMassBloodGlucose).unitDivided(by: HKUnit.liter())
    
    if let samples = try? await HealthKitManager.shared.fetchAllSamplesInInterval(
        for: .bloodGlucose,
        interval: DateInterval(start: Date().addingTimeInterval(-60*60*24), end: Date())) {
        let readings: [BloodGlucoseReading] = samples.map {
            BloodGlucoseReading(
                timestamp: $0.endDate,
                unit: BloodGlucoseReading.Unit.mmolL,
                value: Float($0.quantity.doubleValue(for: bloodGlucoseMMolLUnit))
            )
        }
        
        return readings
    } else {
        return []
    }
}
}
