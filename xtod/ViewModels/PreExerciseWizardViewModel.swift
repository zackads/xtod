//
//  PreExerciseWizardViewModel.swift
//  xtod
//
//  Created by Zack Adlington on 06/02/2026.
//

import Foundation
import Observation

@Observable
class PreExericseWizardViewModel {
    enum BGSource {
        case manual
        case healthkit
    }
    
    enum State {
        case choosingBGSourceStep(choice: BGSource)
        case enteringBGManually
        case gettingBGFromHealthKit
    }
    
    var state: State = .choosingBGSourceStep(choice: .healthkit)
}
