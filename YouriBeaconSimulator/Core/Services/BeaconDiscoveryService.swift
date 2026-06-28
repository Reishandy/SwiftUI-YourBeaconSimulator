//
//  BeaconDiscoveryService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import Foundation
import Observation
import CoreLocation
import CoreBluetooth

@Observable
@MainActor
class BeaconDiscoveryService: NSObject {
	var discoveredBeacons: [DiscoveredBeacon] = []
	
	private var isScanning = false
	private var onNewBeaconFound: (() -> Void)?
	private var refreshTask: Task<Void, Never>?
	
#if os(iOS)
	private var targetConstraint: CLBeaconIdentityConstraint?
	private var locationManager: CLLocationManager?
#elseif os(macOS)
	private var targetUUID: UUID?
	private var centralManager: CBCentralManager?
#endif
	
	override init() {
		super.init()
	}
	
	private func prepareHardware() {
#if os(iOS)
		if locationManager == nil {
			locationManager = CLLocationManager()
			locationManager?.delegate = self
		}
#elseif os(macOS)
		if centralManager == nil {
			centralManager = CBCentralManager(delegate: self, queue: .main)
		}
#endif
	}
	
	func startDiscovery(uuid: UUID, onNewBeaconFound: @escaping () -> Void) {
		guard !isScanning else { return }
		self.isScanning = true
		self.discoveredBeacons = []
		self.onNewBeaconFound = onNewBeaconFound
		
		prepareHardware()
		
#if os(iOS)
		let constraint = CLBeaconIdentityConstraint(uuid: uuid)
		self.targetConstraint = constraint
		locationManager?.startRangingBeacons(satisfying: constraint)
#elseif os(macOS)
		self.targetUUID = uuid
		if centralManager?.state == .poweredOn {
			startScanningForBeacons()
		}
#endif
		
		startRefreshTask()
	}
	
	func stopDiscovery() {
		self.isScanning = false
		self.onNewBeaconFound = nil
		self.refreshTask?.cancel()
		self.refreshTask = nil
		
#if os(iOS)
		if let constraint = targetConstraint {
			locationManager?.stopRangingBeacons(satisfying: constraint)
			self.targetConstraint = nil
		}
#elseif os(macOS)
		centralManager?.stopScan()
#endif
	}
	
	private func startRefreshTask() {
		refreshTask?.cancel()
		
		refreshTask = Task { [weak self] in
			while !Task.isCancelled {
				do {
					try await Task.sleep(for: .seconds(1))
				} catch {
					break
				}
				
				guard let self = self else { return }
				
				let now = Date.now
				var hasChanges = false
				
				// TODO: Check this
				var updatedBeacons = self.discoveredBeacons
				
				for i in 0..<updatedBeacons.count {
					if updatedBeacons[i].isCurrentlyActive &&
						now.timeIntervalSince(updatedBeacons[i].lastSeen) >= 1.0 {
						
						updatedBeacons[i].isCurrentlyActive = false
						hasChanges = true
					}
				}
				
				if hasChanges {
					self.sortDiscoveredBeacons(&updatedBeacons)
					self.discoveredBeacons = updatedBeacons
				}
			}
		}
	}
	
#if os(macOS)
	private func startScanningForBeacons() {
		centralManager?.scanForPeripherals(
			withServices: nil,
			options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
		)
	}
#endif
	
	private func sortDiscoveredBeacons(_ beacons: inout [DiscoveredBeacon]) {
		beacons.sort {
			if $0.isCurrentlyActive != $1.isCurrentlyActive {
				return $0.isCurrentlyActive && !$1.isCurrentlyActive
			}
			
			if $0.uuid != $1.uuid {
				return $0.uuid.uuidString < $1.uuid.uuidString
			}
			
			return $0.accuracy < $1.accuracy
		}
	}
}

#if os(iOS)
extension BeaconDiscoveryService: CLLocationManagerDelegate {
	nonisolated func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		let now = Date.now
		
		Task { @MainActor in
			var updatedBeacons = self.discoveredBeacons
			var hasNewBeacon = false
			
			for beacon in beacons {
				let proximity: BeaconProximity
				switch beacon.proximity {
				case .immediate: proximity = .immediate
				case .near: proximity = .near
				case .far: proximity = .far
				default: proximity = .unknown
				}
				
				let incomingBeacon = DiscoveredBeacon(
					uuid: beacon.uuid,
					major: beacon.major.uint16Value,
					minor: beacon.minor.uint16Value,
					rssi: beacon.rssi,
					accuracy: beacon.accuracy,
					proximity: proximity,
					lastSeen: now,
					isCurrentlyActive: true
				)
				
				if let index = updatedBeacons.firstIndex(where: { $0.id == incomingBeacon.id }) {
					updatedBeacons[index] = incomingBeacon
				} else {
					updatedBeacons.append(incomingBeacon)
					hasNewBeacon = true
				}
			}
			
			self.sortDiscoveredBeacons(&updatedBeacons)
			self.discoveredBeacons = updatedBeacons
			
			if hasNewBeacon {
				self.onNewBeaconFound?()
			}
		}
	}
}
#endif

#if os(macOS)
extension BeaconDiscoveryService: CBCentralManagerDelegate {
	nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
		Task { @MainActor in
			if central.state == .poweredOn && self.isScanning {
				self.startScanningForBeacons()
			}
		}
	}
	
	nonisolated func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		
		// Parse manufacturer data off the MainActor
		guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
			  manufacturerData.count >= 25 else { return }
		
		let iBeaconPrefix = Data([0x4C, 0x00, 0x02, 0x15])
		guard manufacturerData.starts(with: iBeaconPrefix) else { return }
		
		var uuidBytes = [UInt8](repeating: 0, count: 16)
		manufacturerData.copyBytes(to: &uuidBytes, from: 4..<20)
		let beaconUUID = NSUUID(uuidBytes: uuidBytes) as UUID
		
		let major = UInt16(manufacturerData[20]) << 8 | UInt16(manufacturerData[21])
		let minor = UInt16(manufacturerData[22]) << 8 | UInt16(manufacturerData[23])
		let txPower = Int8(bitPattern: manufacturerData[24])
		
		Task { @MainActor in
			let beaconID = "\(beaconUUID.uuidString)-\(major)-\(minor)"
			var finalRSSI = RSSI.intValue
			
			var updatedBeacons = self.discoveredBeacons
			var hasNewBeacon = false
			
			if let index = updatedBeacons.firstIndex(where: { $0.id == beaconID }) {
				let previousBeacon = updatedBeacons[index]
				
				// Only apply smoothing if it hasn't gone completely stale.
				if previousBeacon.isCurrentlyActive {
					let alpha = 0.1
					let smoothed = (Double(RSSI.intValue) * alpha) + (Double(previousBeacon.rssi) * (1.0 - alpha))
					finalRSSI = Int(round(smoothed))
				}
			}
			
			let newBeacon = DiscoveredBeacon(uuid: beaconUUID, major: major, minor: minor, rssi: finalRSSI, txPower: txPower)
			
			if let index = updatedBeacons.firstIndex(where: { $0.id == newBeacon.id }) {
				updatedBeacons[index] = newBeacon
			} else {
				updatedBeacons.append(newBeacon)
				hasNewBeacon = true
			}
			
			self.sortDiscoveredBeacons(&updatedBeacons)
			self.discoveredBeacons = updatedBeacons
			
			if hasNewBeacon {
				self.onNewBeaconFound?()
			}
		}
	}
}
#endif
