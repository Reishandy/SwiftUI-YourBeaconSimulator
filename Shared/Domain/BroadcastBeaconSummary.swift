//
//  BroadcastBeaconSummary.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import Foundation

struct BroadcastBeaconSummary: Codable, Identifiable, Hashable {
	let id: UUID
	let beaconName: String
	let majorID: Int
	let minorID: Int
}
