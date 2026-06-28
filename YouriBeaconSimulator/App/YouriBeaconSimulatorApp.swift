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
	@Environment(\.scenePhase) private var scenePhase
	
#if os(iOS)
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
	
	@State var preferenceService = PreferenceService()
	
	@State var locationPermissionManager = LocationPermissionManager()
	@State var bluetoothPermissionManager = BluetoothPermissionManager()
	@State var notificationPermissionManager = NotificationPermissionManager()
	
	@State var beaconBroadcastService = BeaconBroadcastService()
	@State var beaconDiscoveryService = BeaconDiscoveryService()
	
	var body: some Scene {
		WindowGroup {
			ContentView(
				preferenceService: preferenceService,
				locationPermissionManager: locationPermissionManager,
				bluetoothPermissionManager: bluetoothPermissionManager,
				notificationPermissionManager: notificationPermissionManager,
				beaconBroadcastService: beaconBroadcastService,
				beaconDiscoveryService: beaconDiscoveryService,
				backgroundMonitorService: BackgroundMonitorService.shared
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
		.onChange(of: scenePhase) { oldPhase, newPhase in
			if newPhase == .background {
				beaconBroadcastService.stopBroadcasting()
			}
		}
	}
}
