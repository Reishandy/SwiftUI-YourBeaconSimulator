// Core/Services/BeaconDiscoveryService.swift

import Foundation
import Observation
import CoreLocation
import CoreBluetooth

@Observable
class BeaconDiscoveryService: NSObject {
	private let permissionService: PermissionService
	
	var discoveredBeacons: [DiscoveredBeacon] = []
	
	private var isScanning = false
	private var onNewBeaconFound: (() -> Void)?
	
	private var refreshTimer: Timer?
	
#if os(iOS)
	private var targetConstraint: CLBeaconIdentityConstraint?
	private var locationManager: CLLocationManager?
#elseif os(macOS)
	private var targetUUID: UUID?
	private var centralManager: CBCentralManager?
#endif
	
	init(permissionService: PermissionService) {
		self.permissionService = permissionService
		super.init()
	}
	
	func startDiscovery(uuid: UUID, onNewBeaconFound: @escaping () -> Void) {
		guard !isScanning else { return }
		self.isScanning = true
		self.discoveredBeacons = []
		self.onNewBeaconFound = onNewBeaconFound
		
#if os(iOS)
		guard permissionService.locationAuthorization == .authorizedWhenInUse ||
				permissionService.locationAuthorization == .authorizedAlways else { return }
		
		if locationManager == nil {
			locationManager = CLLocationManager()
			locationManager?.delegate = self
		}
		
		let constraint = CLBeaconIdentityConstraint(uuid: uuid)
		self.targetConstraint = constraint
		locationManager?.startRangingBeacons(satisfying: constraint)
		
#elseif os(macOS)
		guard permissionService.bluetoothAuthorization == .allowedAlways,
			  permissionService.peripheralManager?.state == .poweredOn else { return }
		
		self.targetUUID = uuid
		if centralManager == nil {
			centralManager = CBCentralManager(delegate: self, queue: .main)
		} else {
			startScanningForBeacons()
		}
#endif
		
		startRefreshTimer()
	}
	
	func stopDiscovery() {
		self.isScanning = false
		self.onNewBeaconFound = nil
		self.refreshTimer?.invalidate()
		self.refreshTimer = nil
		
#if os(iOS)
		if let constraint = targetConstraint {
			locationManager?.stopRangingBeacons(satisfying: constraint)
			self.targetConstraint = nil
		}
#elseif os(macOS)
		centralManager?.stopScan()
#endif
	}
	
	private func startRefreshTimer() {
		refreshTimer?.invalidate()
		refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			guard let self = self else { return }
			
			var hasChanges = false
			let now = Date.now
			
			// 1. Mark beacons stale if unheard from for 1 second
			for i in 0..<self.discoveredBeacons.count {
				if self.discoveredBeacons[i].isCurrentlyActive &&
					now.timeIntervalSince(self.discoveredBeacons[i].lastSeen) >= 1.0 {
					
					self.discoveredBeacons[i].isCurrentlyActive = false
					hasChanges = true
				}
			}
			
			// 2. Push inactive beacons to the bottom of the list
			if hasChanges {
				self.discoveredBeacons.sort {
					if $0.isCurrentlyActive != $1.isCurrentlyActive {
						return $0.isCurrentlyActive && !$1.isCurrentlyActive
					}
					return $0.accuracy < $1.accuracy
				}
			}
		}
	}
	
#if os(macOS)
	private func startScanningForBeacons() {
		centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
	}
#endif
}

#if os(iOS)
extension BeaconDiscoveryService: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		let now = Date.now
		
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
			
			if let index = self.discoveredBeacons.firstIndex(where: { $0.id == incomingBeacon.id }) {
				self.discoveredBeacons[index] = incomingBeacon
			} else {
				self.discoveredBeacons.append(incomingBeacon)
				self.onNewBeaconFound?()
			}
		}
		
		self.discoveredBeacons.sort {
			if $0.isCurrentlyActive != $1.isCurrentlyActive {
				return $0.isCurrentlyActive && !$1.isCurrentlyActive
			}
			return $0.accuracy < $1.accuracy
		}
	}
}
#endif

#if os(macOS)
extension BeaconDiscoveryService: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		if central.state == .poweredOn && isScanning {
			startScanningForBeacons()
		}
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
			  manufacturerData.count >= 25 else { return }
		
		let iBeaconPrefix = Data([0x4C, 0x00, 0x02, 0x15])
		guard manufacturerData.starts(with: iBeaconPrefix) else { return }
		
		var uuidBytes = [UInt8](repeating: 0, count: 16)
		manufacturerData.copyBytes(to: &uuidBytes, from: 4..<20)
		let beaconUUID = NSUUID(uuidBytes: uuidBytes) as UUID
		
		guard beaconUUID == targetUUID else { return }
		
		let major = UInt16(manufacturerData[20]) << 8 | UInt16(manufacturerData[21])
		let minor = UInt16(manufacturerData[22]) << 8 | UInt16(manufacturerData[23])
		let txPower = Int8(bitPattern: manufacturerData[24])
		
		let newBeacon = DiscoveredBeacon(uuid: beaconUUID, major: major, minor: minor, rssi: RSSI.intValue, txPower: txPower)
		
		if let index = discoveredBeacons.firstIndex(where: { $0.id == newBeacon.id }) {
			discoveredBeacons[index] = newBeacon
		} else {
			discoveredBeacons.append(newBeacon)
			self.onNewBeaconFound?()
		}
		
		discoveredBeacons.sort {
			if $0.isCurrentlyActive != $1.isCurrentlyActive {
				return $0.isCurrentlyActive && !$1.isCurrentlyActive
			}
			return $0.accuracy < $1.accuracy
		}
	}
}
#endif
