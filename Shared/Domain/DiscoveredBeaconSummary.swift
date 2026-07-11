//
//  DiscoveredBeaconSummary.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

struct DiscoveredBeaconSummary: Codable, Identifiable, Hashable {
	var id: String { "\(major)-\(minor)" }
	let major: UInt16
	let minor: UInt16
	let proximity: BeaconProximity
	let isCurrentlyActive: Bool
}
