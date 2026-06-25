//
//  BroadcastBeacon.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import Foundation
import SwiftData

@Model
class BroadcastBeacon: Identifiable, Equatable {
	var id: UUID
	var timestamp: Date
	
	var projectName: String
	var beaconUUID: String
	var beaconName: String
	var majorID: Int
	var minorID: Int
	
	init(projectName: String, beaconUUID: String, beaconName: String, majorID: Int, minorID: Int) {
		self.id = UUID()
		self.timestamp = .now
		self.projectName = projectName
		self.beaconUUID = beaconUUID
		self.beaconName = beaconName
		self.majorID = majorID
		self.minorID = minorID
	}
	
	// TODO: Share calculated property
}
