//
//  Hypo.swift
//  xtod
//
//  Created by Zack Adlington on 03/02/2026.
//

import Foundation

struct Hypo {
    var requiredAssistance: Bool

    var wasSevere: Bool {
        get { requiredAssistance }
        set { requiredAssistance = newValue }
    }
    
    var timestamp: Date?
}
