//
//  YouriBeaconSimulatorApp.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData

@main
struct YouriBeaconSimulatorApp: App {
	@State var preferenceService: PreferenceService
	@State var permissionService: PermissionService
	@State var beaconBroadcastService: BeaconBroadcastService
	
	init() {
		let permissionService = PermissionService()
		
		self._preferenceService = State(initialValue: PreferenceService())
		self._permissionService = State(initialValue: permissionService)
		self._beaconBroadcastService = State(initialValue: BeaconBroadcastService(permissionService: permissionService))
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView(
				preferenceService: PreferenceService(),
				permissionService: permissionService,
				beaconBroadcastService: beaconBroadcastService
			)
			.modelContainer(for: [BroadcastProject.self, BroadcastBeacon.self])
#if os(macOS)
			.frame(minWidth: 700)
			.frame(maxWidth: 1000)
#endif
		}
#if os(macOS)
		.windowResizability(.contentSize)
#endif
	}
}
