//
//  SharedConnectivityProtocol.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 09/07/26.
//

import Foundation

enum ConnectivityKey {
	static let payload = "payload"
}

enum WatchCommand: Codable {
	case startDiscovery(projectID: UUID)
	case stopDiscovery
	
	case startBroadcast(beaconID: UUID)
	case stopBroadcast
}

struct PhoneState: Codable {
	var isForeground: Bool = false

	var broadcastingBeaconID: UUID? = nil
	var broadcastableProjects: [BroadcastProjectSummary] = []
	
	var discoveringProjectUUID: String? = nil
	var discoveredBeacons: [DiscoveredBeaconSummary] = []
	
	var commandFailedAt: Date? = nil
	var updatedAt: Date = .now
}
