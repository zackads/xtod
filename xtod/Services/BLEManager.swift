//
//  BluetoothManager.swift
//  xtod
//
//  Created by Zack Adlington on 18/02/2026.
//

import Foundation
import CoreBluetooth
internal import Combine

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isScanning = false
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var heartRateBPM: Int? = nil
    
    private var centralManager: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]
    
    // Standard GATT UUIDs for heart rate
    private let heartRateServiceUUID = CBUUID(string: "180D")
    private let heartRateMeasurementCharacteristicUUID = CBUUID(string: "2A37")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Handle Bluetooth state changes
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn: print("✅ Bluetooth is ON")
        case .poweredOff: print("❌ Bluetooth is OFF")
        case .unsupported: print("⚠️ Bluetooth not supported")
        default: print("State: \(central.state.rawValue)")
        }
    }
    
    func startScanning() {
        discoveredDevices.removeAll()
        peripherals.removeAll()
        isScanning = true
        centralManager.scanForPeripherals(
            withServices: [heartRateServiceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
        print("🔎 Scanning started...")
    }
    
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
        print("✋ Scanning stopped.")
    }
    
    // Device discovered
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        if peripherals[peripheral.identifier] == nil {
            peripherals[peripheral.identifier] = peripheral
            discoveredDevices.append(peripheral)
            print("📡 Found: \(peripheral.name ?? "Unknown")")
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
        peripheral.delegate = self
        print("🔗 Connecting to \(peripheral.name ?? "Unknown")")
    }
    
    // Connection success
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        connectedPeripheral = peripheral
        print("✅ Connected to \(peripheral.name ?? "Unknown")")
        peripheral.discoverServices([heartRateServiceUUID])
    }
    
    func disconnect(from peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    // Handle disconnects
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("❌ Disconnected from \(peripheral.name ?? "Unknown")")
        if connectedPeripheral?.identifier == peripheral.identifier {
            connectedPeripheral = nil
            heartRateBPM = nil
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        if let error = error {
            print("Service discovery failed:", error)
            return
        }

        guard let services = peripheral.services else { return }

        for service in services {
            print("Discovered service:", service.uuid)
            peripheral.discoverCharacteristics([heartRateMeasurementCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Characteristic discover failed: ", error)
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("Discovered characteristic:", characteristic.uuid)
            
            if characteristic.uuid == heartRateMeasurementCharacteristicUUID {
                // Subscribe to live heart rate updates
                peripheral.setNotifyValue(true, for: characteristic)
                print("✅ Subscribed to heart rate measurement notifications")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Value update failed:", error)
            return
        }
        
        guard characteristic.uuid == heartRateMeasurementCharacteristicUUID,
            let data = characteristic.value else { return }

        // Heart Rate Measurement (0x2A37) format:
        // Byte 0: flags
        // If (flags & 0x01) == 0 -> HR is UInt8 in byte 1
        // If (flags & 0x01) == 1 -> HR is UInt16 little-endian in bytes 1..2
        let bytes = [UInt8](data)
        guard bytes.count >= 2 else { return }

        let flags = bytes[0]
        let isUInt16 = (flags & 0x01) != 0

        let bpm: Int
        if isUInt16 {
            guard bytes.count >= 3 else { return }
            bpm = Int(UInt16(bytes[1]) | (UInt16(bytes[2]) << 8))
        } else {
            bpm = Int(bytes[1])
        }

        DispatchQueue.main.async {
            self.heartRateBPM = bpm
        }

        print("❤️ HR:", bpm, "bpm")
    }
}
