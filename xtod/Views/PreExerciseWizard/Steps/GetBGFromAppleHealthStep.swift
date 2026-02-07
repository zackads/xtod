//
//  GetBloodGlucoseFromAppleHealthStep.swift
//  xtod
//
//  Created by Zack Adlington on 06/02/2026.
//

import SwiftUI
import Charts

struct GetBGFromAppleHealthStep: View {
    @State var vm: GetBGFromAppleHealthStepViewModel
    let onSuccess: ([BloodGlucoseReading]) -> Void
    let onFailure: () -> Void
    
    init(viewModel: GetBGFromAppleHealthStepViewModel, onSuccess: @escaping ([BloodGlucoseReading]) -> Void, onFailure:  @escaping () -> Void) {
        self.vm = viewModel
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    var body: some View {
        VStack(spacing: 20) {
            switch vm.state {
            case .requestingHKAuthorization:
                ProgressView("Requesting HealthKit authorisation...")
                    .task {
                        await vm.requestAuthorization()
                    }
            case .HKAuthorizedFetchingData:
                ProgressView("Syncing HealthKit data...")
            case .deniedHKAuthorization:
                Text("Uh oh!  I need you to authorize Apple Health integration in order to read your blood glucose.  Would you like to try again, or enter a manual reading?")
                
                Button {
                    vm.state = .requestingHKAuthorization
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                        Text("Let's try authorising Apple Health integration again")
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    onFailure()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                        Text("I'll enter my blood glucose manually instead")
                    }
                }
                .buttonStyle(.borderedProminent)
            case .HKAuthorizedButNoData:
                Text("Uh oh!  The integration worked successfully, but no blood glucose readings were found.")
                
                Button {
                    onFailure()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                        Text("I'll enter my blood glucose manually instead")
                    }
                }
                .buttonStyle(.borderedProminent)
            case .HKAuthorizedButStaleData:
                Text("Uh oh!  The integration worked successfully, but the last blood glucose reading was more than 15 minutes ago.")
                
                if let lastReading = vm.mostRecentReading {
                    Text("Last reading was \(lastReading.value) at \(lastReading.timestamp)")
                }
                
                Button {
                    onFailure()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                        Text("I'll enter my blood glucose manually instead")
                    }
                }
                .buttonStyle(.borderedProminent)
            case .HKAuthorizedWithCurrentData:
                if let lastReading = vm.mostRecentReading {
                    Text("According to Apple Health data, your blood glucose at \(lastReading.timestamp.formatted(date: .omitted, time: .shortened)) was...")
                    
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.gray.gradient)
                        .frame(width: 200, height: 150)
                        .overlay {
                            (Text(lastReading.value, format: .number.precision(.fractionLength(1))) + Text(" \(lastReading.unit.rawValue)"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                        }
                    
                    BloodGlucoseChartView(readings: vm.readings)
                    
                    Button("This isn't right, I'll enter my blood glucose manually") {
                        onFailure()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Continue") {
                        onSuccess(vm.readings)
                    }
                    .buttonStyle(.borderedProminent)
                }
            case .error(let errorMessage):
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                
                Button {
                    onFailure()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                        Text("I'll enter my blood glucose manually instead")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle("Blood glucose")
    }
}

@MainActor
final class HealthDataViewModelMock: GetBGFromAppleHealthStepViewModel {
    init(
        state: GetBGFromAppleHealthStepViewModel.State = .requestingHKAuthorization,
        readings: [BloodGlucoseReading] = []
    ) {
        super.init()
        self.state = state
        self.readings = readings
    }
    
    override func requestAuthorization() async {}
}

#Preview("Requesting authorization") {
    let now = Date()
    let vm = HealthDataViewModelMock(state: .requestingHKAuthorization)
    GetBGFromAppleHealthStep(viewModel: vm, onSuccess: { _ in }, onFailure: { })
}

#Preview("Denied authorization") {
    let vm = HealthDataViewModelMock(state: .deniedHKAuthorization)
    GetBGFromAppleHealthStep(viewModel: vm, onSuccess: { _ in }, onFailure: { })
}

#Preview("Authorized, fetching data") {
    let vm = HealthDataViewModelMock(state: .HKAuthorizedFetchingData)
    GetBGFromAppleHealthStep(viewModel: vm, onSuccess: { _ in }, onFailure: { })
}

#Preview("Authorized, no data") {
    let vm = HealthDataViewModelMock(state: .HKAuthorizedButNoData)
    GetBGFromAppleHealthStep(viewModel: vm, onSuccess: { _ in }, onFailure: { })
}

#Preview("Authorized, stale data") {
    let readings = [BloodGlucoseReading(timestamp: Date().addingTimeInterval(-24 * 60 * 60), unit: BloodGlucoseReading.Unit.mmolL, value: 6.5)]
    let vm = HealthDataViewModelMock(state: .HKAuthorizedButStaleData, readings: readings)
    GetBGFromAppleHealthStep(viewModel: vm, onSuccess: { _ in }, onFailure: { })
}

#Preview("Authorized, fresh data") {
    let readings = [BloodGlucoseReading(timestamp: Date(), unit: BloodGlucoseReading.Unit.mmolL, value: 6.5)]
    let vm = HealthDataViewModelMock(state: .HKAuthorizedWithCurrentData, readings: readings)
    GetBGFromAppleHealthStep(viewModel: vm, onSuccess: { _ in }, onFailure: { })
}

//#Preview("Requesting permission") {
//    let now = Date()
//    let vm = HealthDataViewModelMock(last24HrsBloodGlucose: nil, isRequestingAuthorization: true)
//    PreExerciseWizardView(viewModel: vm)
//}
//
//
//#Preview("Permission granted") {
//    let now = Date()
//    let vm = HealthDataViewModelMock(last24HrsBloodGlucose: [
//        (now.addingTimeInterval(-15 * 60), 4.4),
//        (now.addingTimeInterval(-10 * 60), 4.5),
//        (now.addingTimeInterval(-5 * 60), 4.6),
//        (now, 4.7),
//    ])
//    PreExerciseWizardView(viewModel: vm)
//}

