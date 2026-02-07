//
//  BloodGlucoseChartView.swift
//  xtod
//
//  Created by Zack Adlington on 06/02/2026.
//
import SwiftUI
import Charts

struct BloodGlucoseChartView: View {
    let readings: [BloodGlucoseReading]
    
    var body: some View {
        Chart {
            ForEach(readings, id: \.self) { reading in
                PointMark(
                    x: .value("Time", reading.timestamp),
                    y: .value("Blood glucose", reading.value)
                )
            }
        }
    }
}
