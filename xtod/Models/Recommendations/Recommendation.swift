//
//  Recommendation 2.swift
//  xtod
//
//  Created by Zack Adlington on 12/02/2026.
//


struct Recommendation {
    enum Kind {
        case fuel
        case insulinCorrection
        case wait
        case goAgain
        case goAhead
        case stop
        case caution
    }
    
    var name: String
    var kind: Kind
    var reasons: [Reason]
    var instruction: String
}
