//
//  BeaconBroadcastService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import Foundation
import CoreBluetooth
import CoreLocation
import Observation

@Observable
class BeaconBroadcastService: NSObject, CBPeripheralManagerDelegate {
	private var peripheralManager: CBPeripheralManager?
	
	private(set) var activeBeacon: BroadcastBeacon?
	private var pendingTxPower: Int8?
	
	override init() {
		super.init()
	}
	
	func prepareHardware() {
		if peripheralManager == nil {
			peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
		}
	}
	
	func startBroadcasting(beacon: BroadcastBeacon, txPower: Int8) {self.activeBeacon = beacon
		self.pendingTxPower = txPower
		
		if peripheralManager == nil {
			peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
		}
		
		if peripheralManager?.state == .poweredOn {
			executeBroadcast()
		}
	}
	
	private func executeBroadcast() {
		guard let manager = peripheralManager, manager.state == .poweredOn,
			  let beacon = activeBeacon, let txPower = pendingTxPower,
			  let project = beacon.project, let uuid = UUID(uuidString: project.proximityUUID) else { return }
		
		let major = UInt16(clamping: beacon.majorID)
		let minor = UInt16(clamping: beacon.minorID)
		let beaconPeripheralData: [String: Any]
		
#if os(macOS)
		var advertisementBytes = [UInt8](repeating: 0, count: 21)
		let uuidBytes = withUnsafeBytes(of: uuid.uuid) { Array($0) }
		for i in 0..<16 { advertisementBytes[i] = uuidBytes[i] }
		
		advertisementBytes[16] = UInt8(major >> 8)
		advertisementBytes[17] = UInt8(major & 0x00FF)
		advertisementBytes[18] = UInt8(minor >> 8)
		advertisementBytes[19] = UInt8(minor & 0x00FF)
		advertisementBytes[20] = UInt8(bitPattern: txPower)
		
		beaconPeripheralData = ["kCBAdvDataAppleBeaconKey": Data(advertisementBytes)]
#else
		let beaconRegion = CLBeaconRegion(uuid: uuid, major: major, minor: minor, identifier: beacon.beaconName)
		guard let data = beaconRegion.peripheralData(withMeasuredPower: NSNumber(value: txPower)) as? [String: Any] else { return }
		beaconPeripheralData = data
#endif
		
		manager.startAdvertising(beaconPeripheralData)
	}
	
	func stopBroadcasting() {
		peripheralManager?.stopAdvertising()
		activeBeacon = nil
		pendingTxPower = nil
	}
	
	func updateTxPower(to newPower: Int8) {
		guard let currentBeacon = activeBeacon else { return }
		stopBroadcasting()
		startBroadcasting(beacon: currentBeacon, txPower: newPower)
	}
	
	nonisolated func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
		Task { @MainActor in
			if peripheral.state == .poweredOn {
				if self.activeBeacon != nil {
					self.executeBroadcast()
				}
			} else {
				if self.activeBeacon != nil {
					self.stopBroadcasting()
				}
			}
		}
	}
}
