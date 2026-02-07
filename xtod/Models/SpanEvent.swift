//
//  SpanEvent.swift
//  xtod
//
//  Created by Zack Adlington on 03/02/2026.
//

import Foundation

protocol SpanEvent {
    var start: Date { get }
    var finish: Date { get }
}
