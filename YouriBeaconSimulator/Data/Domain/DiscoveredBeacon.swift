//
//  DiscoveredBeacon.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import Foundation

struct DiscoveredBeacon: Identifiable, Equatable, Sendable, Hashable {
	var id: String { "\(uuid.uuidString)-\(major)-\(minor)" }
	
	let uuid: UUID
	let major: UInt16
	let minor: UInt16
	
	var rssi: Int
	var accuracy: Double // Distance estimation in meters
	var proximity: BeaconProximity
	var lastSeen: Date
	
	var isCurrentlyActive: Bool {
		Date.now.timeIntervalSince(lastSeen) < 3.0 // 3 Seconds stale treshold
	}
}

extension DiscoveredBeacon {
	/// Custom initializer for macOS CoreBluetooth parsing
	init(uuid: UUID, major: UInt16, minor: UInt16, rssi: Int, txPower: Int8) {
		self.uuid = uuid
		self.major = major
		self.minor = minor
		self.rssi = rssi
		self.lastSeen = .now
		
		if rssi == 127 || rssi >= 0 {
			self.accuracy = -1.0 // Invalid signal
		} else {
			let ratio = Double(rssi) / Double(txPower)
			if ratio < 1.0 {
				self.accuracy = pow(ratio, 10.0)
			} else {
				// Log-distance path loss approximation
				self.accuracy = 0.89976 * pow(ratio, 7.7095) + 0.111
			}
		}
		
		if self.accuracy < 0 {
			self.proximity = .unknown
		} else if self.accuracy < 0.5 {
			self.proximity = .immediate
		} else if self.accuracy < 3.0 {
			self.proximity = .near
		} else {
			self.proximity = .far
		}
	}
}
