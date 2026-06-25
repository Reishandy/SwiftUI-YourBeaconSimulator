//
//  BroadcastProjectGroup.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import Foundation

struct BroadcastProjectGroup: Identifiable {
	var id: UUID { project.id }
	let project: BroadcastProject
	let beacons: [BroadcastBeacon]
}
