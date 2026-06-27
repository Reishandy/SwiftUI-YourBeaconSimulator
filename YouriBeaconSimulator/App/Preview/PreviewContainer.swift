//
//  PreviewContainer.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftData
import SwiftUI

@MainActor
class PreviewContainer {
	static let shared: ModelContainer = {
		do {
			let schema = Schema([BroadcastProject.self, BroadcastBeacon.self])
			let config = ModelConfiguration(isStoredInMemoryOnly: true)
			let container = try ModelContainer(for: schema, configurations: [config])
			let context = container.mainContext
			
			let project1 = BroadcastProject(name: "Lobby System", proximityUUID: UUID().uuidString)
			let project2 = BroadcastProject(name: "Meeting Rooms", proximityUUID: UUID().uuidString)
			let project3 = BroadcastProject(name: "Cafeteria", proximityUUID: UUID().uuidString)
			let project4 = BroadcastProject(name: "Parking Garage", proximityUUID: UUID().uuidString)
			
			let beacon1 = BroadcastBeacon(beaconName: "Main Entrance", majorID: 2, minorID: 100)
			let beacon2 = BroadcastBeacon(beaconName: "Reception Desk", majorID: 1, minorID: 200)
			let beacon3 = BroadcastBeacon(beaconName: "Elevator Bank A", majorID: 1, minorID: 201)
			
			let beacon4 = BroadcastBeacon(beaconName: "Room A", majorID: 2, minorID: 101)
			let beacon5 = BroadcastBeacon(beaconName: "Room B", majorID: 1, minorID: 102)
			let beacon6 = BroadcastBeacon(beaconName: "Conference Hall", majorID: 3, minorID: 150)
			
			let beacon7 = BroadcastBeacon(beaconName: "Main Food Court", majorID: 1, minorID: 10)
			let beacon8 = BroadcastBeacon(beaconName: "Coffee Shop", majorID: 3, minorID: 20)
			
			let beacon9 = BroadcastBeacon(beaconName: "Level 1 North", majorID: 5, minorID: 1)
			let beacon10 = BroadcastBeacon(beaconName: "Level 2 South", majorID: 4, minorID: 2)
			
			beacon1.project = project1
			beacon2.project = project1
			beacon3.project = project1
			
			beacon4.project = project2
			beacon5.project = project2
			beacon6.project = project2
			
			beacon7.project = project3
			beacon8.project = project3
			
			beacon9.project = project4
			beacon10.project = project4
			
			context.insert(project1)
			context.insert(project2)
			context.insert(project3)
			context.insert(project4)
			
			return container
		} catch {
			fatalError("Failed to create preview SwiftData container: \(error)")
		}
	}()
	
	static var discoveredBeaconPreviews: [DiscoveredBeacon] {
		let defaultUUID = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
		let now = Date.now
		let staleDate = now.addingTimeInterval(-60.0) // 1 minute ago
		return [
			DiscoveredBeacon(uuid: defaultUUID, major: 1, minor: 100, rssi: -35, accuracy: 0.2, proximity: .immediate, lastSeen: now),
			
			DiscoveredBeacon(uuid: defaultUUID, major: 1, minor: 101, rssi: -60, accuracy: 1.5, proximity: .near, lastSeen: now),
			
			DiscoveredBeacon(uuid: defaultUUID, major: 1, minor: 102, rssi: -85, accuracy: 5.0, proximity: .far, lastSeen: now),
			
			DiscoveredBeacon(uuid: defaultUUID, major: 1, minor: 103, rssi: 0, accuracy: -1.0, proximity: .unknown, lastSeen: now),
			
			DiscoveredBeacon(uuid: defaultUUID, major: 2, minor: 200, rssi: -90, accuracy: 8.0, proximity: .unknown, lastSeen: staleDate, isCurrentlyActive: false)
		]
	}
}
