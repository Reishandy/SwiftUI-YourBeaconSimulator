//
//  WatchPreviewData.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import Foundation

#if DEBUG
enum WatchPreviewData {
	static let projects: [BroadcastProjectSummary] = [
		BroadcastProjectSummary(id: UUID(), name: "Lobby System", beacons: [
			BroadcastBeaconSummary(id: UUID(), beaconName: "Main Entrance", majorID: 2, minorID: 100),
			BroadcastBeaconSummary(id: UUID(), beaconName: "Reception Desk", majorID: 1, minorID: 200),
			BroadcastBeaconSummary(id: UUID(), beaconName: "Elevator Bank A", majorID: 1, minorID: 201)
		]),
		BroadcastProjectSummary(id: UUID(), name: "Meeting Rooms", beacons: [
			BroadcastBeaconSummary(id: UUID(), beaconName: "Room A", majorID: 2, minorID: 101),
			BroadcastBeaconSummary(id: UUID(), beaconName: "Room B", majorID: 1, minorID: 102)
		])
	]
	
	static let discoveredBeacons: [DiscoveredBeaconSummary] = [
		DiscoveredBeaconSummary(major: 1, minor: 100, proximity: .immediate, isCurrentlyActive: true),
		DiscoveredBeaconSummary(major: 1, minor: 101, proximity: .near, isCurrentlyActive: true),
		DiscoveredBeaconSummary(major: 1, minor: 102, proximity: .far, isCurrentlyActive: true),
		DiscoveredBeaconSummary(major: 2, minor: 200, proximity: .unknown, isCurrentlyActive: false)
	]
	
	static var idleForegroundState: PhoneState {
		PhoneState(
			isForeground: true,
			broadcastingBeaconID: nil,
			broadcastableProjects: projects,
			discoveringProjectID: nil,
			discoveredBeacons: [],
			commandFailedAt: nil,
			updatedAt: .now
		)
	}
	
	static var discoveringState: PhoneState {
		PhoneState(
			isForeground: true,
			broadcastingBeaconID: nil,
			broadcastableProjects: projects,
			discoveringProjectID: projects.first?.id ?? UUID(),
			discoveredBeacons: discoveredBeacons,
			commandFailedAt: nil,
			updatedAt: .now
		)
	}
	
	static var broadcastingState: PhoneState {
		PhoneState(
			isForeground: true,
			broadcastingBeaconID: projects[0].beacons[0].id,
			broadcastableProjects: projects,
			discoveringProjectID: nil,
			discoveredBeacons: [],
			commandFailedAt: nil,
			updatedAt: .now
		)
	}
	
	static var backgroundState: PhoneState {
		PhoneState(
			isForeground: false,
			updatedAt: .now
		)
	}
}
#endif
