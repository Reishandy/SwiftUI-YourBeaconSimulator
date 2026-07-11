//
//  BroadcastProjectSummary.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import Foundation

struct BroadcastProjectSummary: Codable, Identifiable, Hashable {
	let id: UUID
	let name: String
	let proximityUUID: String
	let beacons: [BroadcastBeaconSummary]
}
