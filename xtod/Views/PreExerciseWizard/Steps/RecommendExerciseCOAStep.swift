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
            List(recommendations, id: \.name) { rec in
                recommendationCard(recommendation: rec)
            }
        }
    }
    
    private func recommendExerciseCOA(preExerciseCondition: PreExerciseCondition) -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        if let hypo = preExerciseCondition.hypoInLast24Hours {
            if hypo.wasSevere {
                return [
                    Recommendation(
                        name: "Do not exercise",
                        kind: .stop,
                        reasons: [
                            Reason(
                                name: "You had a severe hypo in the last 24 hours",
                                description: "Your risk of having another severe hypo is too high to exercise safely."
                            )
                        ],
                        instruction: "Wait until 24 hours have passed since your last severe hypo."
                    )
                ]
            } else {
                recommendations.append(
                    Recommendation(
                        name: "Be careful",
                        kind: .caution,
                        reasons: [
                            Reason(
                                name: "You had a hypo in the last 24 hours",
                                description: "Your risk of having another hypo is still high."
                            )
                        ],
                        instruction: "You had a hypo in the last 24 hours, so make sure you have extra carb snacks with you, don't exercise alone and pay extra attention to your blood sugar going low."
                    )
                )
            }
        }
        
        guard let bg = preExerciseCondition.mostRecentBGReading else {
            fatalError("No blood glucose data.")
        }
        
        switch bg.value {
        case ..<3.5:
            recommendations.append(contentsOf: [
                Recommendation(
                    name: "Eat 20g fast acting carbs",
                    kind: .fuel,
                    reasons: [Reason(name: "Your blood glucose is too low.")],
                    instruction: "It looks like you're having a hypo, so consume 20g of carbs as soon as possible."
                ),
                Recommendation(
                    name: "Wait 15 minutes",
                    kind: .wait,
                    reasons: [Reason(name: "The carbs you just ate need time to take effect.")],
                    instruction: "Give the carbs some time to take effect."
                ),
                Recommendation(
                    name: "Check blood glucose again",
                    kind: .goAgain,
                    reasons: [Reason(name: "To measure the effect of the carbs you just ate.")],
                    instruction: "Go through the pre-exercise plan again to make sure you're ready to go."
                ),
                Recommendation(
                    name: "Wait 45 minutes before exercising",
                    kind: .caution,
                    reasons: [Reason(name: "To reduce risk of another hypo.")],
                    instruction: "Don't exercise until at least 45 minutes have passed with your blood glucose above 3.5 mmol/L."
                ),
            ])
        case 3.5..<5.7:
            recommendations.append(contentsOf: [
                Recommendation(
                    name: "Eat 20g fast acting carbs", // TODO: Add a checkbox here?
                    kind: .fuel,
                    reasons: [Reason(name: "Your blood glucose is too low.")],
                    instruction: "Your blood glucose is too low to start exercise right now.  Eat a small snack to bring your blood glucose into the right range."
                ),
                Recommendation(
                    name: "Wait 15 minutes", // TODO: Add a timer button here?
                    kind: .wait,
                    reasons: [Reason(name: "")],
                    instruction: "Give the carbs some time to take effect."
                ),
                Recommendation(
                    name: "Check again", // TODO: Add a "go back" button here
                    kind: .goAgain,
                    reasons: [Reason(name: "To measure the effect of the carbs you just ate.")],
                    instruction: "Go through the pre-exercise plan again to make sure you're ready to go."
                ),
            ])
        case 5.7..<7:
            recommendations.append(contentsOf: [
                Recommendation(
                    name: "Eat 15g fast acting carbs", // TODO: Add a checkbox here?
                    kind: .fuel,
                    reasons: [Reason(name: "Your blood glucose is in the right range. 15g will protect you in the early parts of exercise.")],
                    instruction: "Your blood glucose is in the right range, but eating something small now will protect you."
                ),
                Recommendation(
                    name: "Go ahead",
                    kind: .goAhead, reasons: [], instruction: "Once you've eaten 15g carbs, you can start exercise.")
            ])
        case 7..<15:
            recommendations.append(contentsOf: [
                Recommendation(
                    name: "Go ahead",
                    kind: .goAhead, reasons: [], instruction: "You're good to go!  No need to do anything extra: start exercising immediately.")
            ])
        case 15...:
            guard let ketones = preExerciseCondition.mostRecentKetoneReading else {
                fatalError()
            }
            
            if ketones.value > 1.5 {
                recommendations.append(contentsOf: [
                    Recommendation(
                        name: "Take your usual correction dose of insulin",
                        kind: .insulinCorrection,
                        reasons: [],
                        instruction: "Your blood sugar is too high, so needs to be corrected."
                    ),
                    Recommendation(
                        name: "Do not exercise",
                        kind: .stop,
                        reasons: [],
                        instruction: "Exercising with high blood ketones is dangerous.  Wait 24 hours."
                    )
                ])
            } else {
                recommendations.append(contentsOf: [
                    Recommendation(
                        name: "Take one third of your usual correction dose of insulin",
                        kind: .insulinCorrection,
                        reasons: [],
                        instruction: "Your blood sugar is too high, so needs to be corrected.  Reduce your usual correction dose by one third to account for the exercise you're about to do."
                    ),
                    Recommendation(
                        name: "Go ahead",
                        kind: .goAhead, reasons: [], instruction: "You're good to go!  Once you've taken your correction dose you can start exercising immediately."
                    )
                ])
            }
        default:
            fatalError("Blood glucose value is NaN")
        }
    
        
        return recommendations
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
            .insulinCorrection: "syringe",
            .wait:              "clock",
            .goAgain:           "backward",
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

#Preview("No hypo, bg 3.0") {
    let preExerciseCondition = PreExerciseCondition(
        bgReadings: [BloodGlucoseReading(value: 3.0)],
        ketoneReadings: [],
        hypoInLast24Hours: nil
    )
    
    RecommendExerciseCOAStep(preExerciseCondition: preExerciseCondition)
}

#Preview("No hypo, bg 4.5") {
    let preExerciseCondition = PreExerciseCondition(
        bgReadings: [BloodGlucoseReading(value: 4.5)],
        ketoneReadings: [],
        hypoInLast24Hours: nil
    )
    
    RecommendExerciseCOAStep(preExerciseCondition: preExerciseCondition)
}


#Preview("No hypo, bg 6.5") {
    let preExerciseCondition = PreExerciseCondition(
        bgReadings: [BloodGlucoseReading(value: 6.5)],
        ketoneReadings: [],
        hypoInLast24Hours: nil
    )
    
    RecommendExerciseCOAStep(preExerciseCondition: preExerciseCondition)
}


#Preview("No hypo, bg 8.5") {
    let preExerciseCondition = PreExerciseCondition(
        bgReadings: [BloodGlucoseReading(value: 8.5)],
        ketoneReadings: [],
        hypoInLast24Hours: nil
    )
    
    RecommendExerciseCOAStep(preExerciseCondition: preExerciseCondition)
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
