//
//  RecommendExerciseCOAStep.swift
//  xtod
//
//  Created by Zack Adlington on 12/02/2026.
//

import SwiftUI

struct RecommendExerciseCOAStep: View {
    let preExerciseCondition: PreExerciseCondition
    
    var body: some View {
        let recommendations = recommendExerciseCOA(preExerciseCondition: preExerciseCondition)
        
        return VStack {
            Text("Hello world!")
            List(recommendations, id: \.name) { rec in
                recommendationCard(recommendation: rec)
            }
        }
    }
    
    private func recommendExerciseCOA(preExerciseCondition: PreExerciseCondition) -> [Recommendation] {
        if let hypo = preExerciseCondition.hypoInLast24Hours {
            if hypo.wasSevere {
                return [Recommendation(
                    name: "Do not exercise",
                    kind: .stop,
                    reasons: [
                        Reason(
                            name: "You had a severe hypo in the last 24 hours",
                            description: "Your risk of having another severe hypo is too high to exercise safely."
                        )
                    ],
                    instruction: "Wait until 24 hours have passed since your last severe hypo."
                )]
            } else {
                return [
                    Recommendation(
                        name: "Go ahead",
                        kind: .goAhead,
                        reasons: [],
                        instruction: "Don't exercise alone, and make sure you have extra carb snacks with you."
                    ),
                    Recommendation(
                        name: "Be careful",
                        kind: .caution,
                        reasons: [
                            Reason(
                                name: "You had a hypo in the last 24 hours",
                                description: "Your risk of having another hypo is still high."
                            )
                        ],
                        instruction: "Don't exercise alone, and make sure you have extra carb snacks with you."
                    ),
                ]
            }
        }
        
        return []
    }
    
    private func recommendationCard(recommendation: Recommendation) -> AnyView {
        let backgroundColours: [Recommendation.Kind: Color] = [
            .fuel:              Color.gray.opacity(0.12),
            .insulinCorrection: Color.orange.opacity(0.12),
            .wait:              Color.gray.opacity(0.12),
            .goAgain:           Color.gray.opacity(0.12),
            .goAhead:           Color.green.opacity(0.12),
            .stop:              Color.red.opacity(0.12),
            .caution:           Color.orange.opacity(0.12)
        ]
        
        let icons: [Recommendation.Kind: String] = [
            .fuel:              "fuelpump",
            .insulinCorrection: "",
            .wait:              "",
            .goAgain:           "",
            .goAhead:           "figure.run",
            .stop:              "xmark",
            .caution:           "exclamationmark.triangle"
        ]
        
        let cardBackground = backgroundColours[recommendation.kind]
        let cardIcon = icons[recommendation.kind] ?? ""
        
        return AnyView(
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(recommendation.reasons, id: \.name) { reason in
                        Text(reason.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let desc = reason.description {
                            Text(desc)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
            } label: {
                VStack(alignment: .leading) {
                    Label(recommendation.name, systemImage: cardIcon)
                        .font(.headline)
                        .padding(.vertical, 6)
                    Text(recommendation.instruction)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .listRowBackground(cardBackground)
        )
    }
}

#Preview("Non-severe hypo last 24hrs") {
    let preExerciseCondition = PreExerciseCondition(
        bgReadings: [BloodGlucoseReading(value: 6.5)],
        ketoneReadings: [],
        hypoInLast24Hours: Hypo(requiredAssistance: false)
    )
    
    RecommendExerciseCOAStep(preExerciseCondition: preExerciseCondition)
}

#Preview("Severe hypo last 24hrs") {
    let preExerciseCondition = PreExerciseCondition(
        bgReadings: [BloodGlucoseReading(value: 6.5)],
        ketoneReadings: [],
        hypoInLast24Hours: Hypo(requiredAssistance: true)
    )
    
    RecommendExerciseCOAStep(preExerciseCondition: preExerciseCondition)
}
