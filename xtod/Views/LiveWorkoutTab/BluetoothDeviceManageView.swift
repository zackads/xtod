//
//  BluetoothDeviceManageView.swift
//  xtod
//
//  Created by Zack Adlington on 18/02/2026.
//

import SwiftUI
import CoreBluetooth
internal import Combine

private enum LiveExerciseStep: Hashable {
    case connection
    case inExercise
}

struct BluetoothDeviceManageView: View {
    @State private var path: [LiveExerciseStep] = []
    @StateObject private var bleManager = BLEManager()
    
    var body: some View {
        NavigationStack(path: $path) {
            LiveHeartRateView(bleManager: bleManager)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationDestination(for: LiveExerciseStep.self) { step in
                switch step {
                case .connection:
                    LiveHeartRateView(bleManager: bleManager)
                case .inExercise:
                    Text("TODO")
                }
                
            }
        }
    }
}

private struct LiveHeartRateView: View {
    @ObservedObject var bleManager: BLEManager

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: CGFloat = 0.25
    @State private var pulseTimerCancellable: AnyCancellable?

    private var deviceName: String {
        bleManager.connectedPeripheral?.name ?? "Unknown"
    }
    private var isConnected: Bool {
        bleManager.connectedPeripheral != nil
    }

    private func startPulseTimer() {
        // Stop any existing timer.
        pulseTimerCancellable?.cancel()
        pulseTimerCancellable = nil

        // Constant pulse at 60 BPM (1 beat per second).
        pulseTimerCancellable = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                firePulse()
            }
    }

    private func firePulse() {
        // Reset, then animate outward ring.
        pulseScale = 1.0
        pulseOpacity = 0.35
        withAnimation(.easeOut(duration: 0.55)) {
            pulseScale = 1.35
            pulseOpacity = 0.0
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("Live heart rate")
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack(spacing: 6) {
                    Image(systemName: bleManager.connectedPeripheral == nil ? "bolt.slash" : "bolt.horizontal.circle.fill")
                        .imageScale(.medium)
                    Text("Connected to \(deviceName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            ZStack {
                // Pulse ring (only when connected)
                if isConnected {
                    Circle()
                        .stroke(lineWidth: 6)
                        .opacity(pulseOpacity)
                        .scaleEffect(pulseScale)
                        .animation(.easeOut(duration: 0.55), value: pulseScale)
                        .animation(.easeOut(duration: 0.55), value: pulseOpacity)
                }

                // Main badge
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))

                    if let bpm = bleManager.heartRateBPM {
                        Text("\(bpm)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                        Text("BPM")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("—")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                        Text(bleManager.connectedPeripheral == nil ? "Not connected" : "Waiting for data…")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(28)
            }
            .frame(width: 220, height: 220)
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    if bleManager.isScanning {
                        Label("Scanning…", systemImage: "dot.radiowaves.left.and.right")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Stop scanning") {
                            bleManager.stopScanning()
                        }
                        .buttonStyle(.borderedProminent)
                    } else if bleManager.connectedPeripheral == nil {
                        Button("Search for heart rate monitors") {
                            bleManager.startScanning()
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                    }
                    List(bleManager.discoveredDevices.filter { $0.name != nil } , id: \.identifier) { peripheral in
                        HStack {
                            Text(peripheral.name ?? "Unknown")
                                .font(.headline)
    
                            Spacer()
    
                            if bleManager.connectedPeripheral?.identifier == peripheral.identifier {
                                Button("Disconnect") {
                                    bleManager.disconnect(from: peripheral)
                                }
                            } else {
                                Button("Connect") {
                                    bleManager.stopScanning()
                                    bleManager.connect(to: peripheral)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("Live")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if isConnected {
                startPulseTimer()
            }
        }
        .onDisappear {
            pulseTimerCancellable?.cancel()
            pulseTimerCancellable = nil
        }
        .onChange(of: isConnected) { _, connected in
            if connected {
                startPulseTimer()
            } else {
                pulseTimerCancellable?.cancel()
                pulseTimerCancellable = nil
                // Reset visuals so the ring isn't left mid-animation.
                pulseScale = 1.0
                pulseOpacity = 0.25
            }
        }
    }
}

#Preview {
    BluetoothDeviceManageView()
}
