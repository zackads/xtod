//
//  HypoRiskAssessor.swift
//  xtod
//
//  Created by Zack Adlington on 07/02/2026.
//

import Foundation

struct HypoRiskAssessor {
    private let hypoBelowThreshold = 4.0 // https://www.nhs.uk/conditions/low-blood-sugar-hypoglycaemia/
    private let relevantTimeWindow = DateInterval(
        start: Date().addingTimeInterval(-(24 * 60 * 60)),
        end: Date().addingTimeInterval(-(0.5 * 60 * 60))
    )

    func hadHypoInLast24Hours(readings: [BloodGlucoseReading], now: Date = Date()) -> Bool? {
        guard dense(readings: readings) && cover(readings: readings, interval: relevantTimeWindow) else {
            return nil
        }
        
        return readings.contains { reading in
            reading.unit == BloodGlucoseReading.Unit.mmolL && reading.value < hypoBelowThreshold && reading.timestamp >= relevantTimeWindow.start
        }
    }
    
    private func dense(readings: [BloodGlucoseReading]) -> Bool {
        guard readings.count >= 2 else {
            // With 0 or 1 readings, the condition is trivially satisfied
            return true
        }

        let sorted = readings.sorted { $0.timestamp < $1.timestamp }

        let maxGap: TimeInterval = 30 * 60 // 30 minutes in seconds

        for i in 1..<sorted.count {
            let gap = sorted[i].timestamp.timeIntervalSince(sorted[i - 1].timestamp)
            if gap > maxGap {
                return false
            }
        }

        return true
    }
    
    private func cover(readings: [BloodGlucoseReading], interval: DateInterval) -> Bool {
        guard readings.count >= 2 else {
            return false
        }

        let sorted = readings.sorted { $0.timestamp < $1.timestamp }

        guard let first = sorted.first, let last = sorted.last else {
            return false
        }

        return first.timestamp <= interval.start
            && last.timestamp >= interval.end
    }
}
