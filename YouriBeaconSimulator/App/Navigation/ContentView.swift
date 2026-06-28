//
//  ContentView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	
	var isPreview: Bool = false
	
	let preferenceService: PreferenceService
	let locationPermissionManager: LocationPermissionManager
	let bluetoothPermissionManager: BluetoothPermissionManager
	let notificationPermissionManager: NotificationPermissionManager
	
	let beaconBroadcastService: BeaconBroadcastService
	let beaconDiscoveryService: BeaconDiscoveryService
	let backgroundMonitorService: BackgroundMonitorService
	
	var body: some View {
		TabView {
			BroadcastView(
				broadcastViewModel: BroadcastViewModel(
					modelContext: modelContext,
					bluetoothManager: bluetoothPermissionManager,
					broadcastService: beaconBroadcastService
				)
			)
			.tabItem {
				Label("Broadcast", systemImage: "sensor.radiowaves.left.and.right.fill")
			}
			
			DiscoverView(
				discoverViewModel: DiscoverViewModel(
					modelContext: modelContext,
					preferenceService: preferenceService,
					locationPermissionManager: locationPermissionManager,
					bluetoothPermissionManager: bluetoothPermissionManager,
					notificationPermissionManager: notificationPermissionManager,
					discoveryService: beaconDiscoveryService,
					backgroundMonitorService: backgroundMonitorService
				)
			)
			.tabItem {
				Label("Discover", systemImage: "dot.radiowaves.up.forward")
			}
		}
	}
}

#Preview {
	ContentView(
		isPreview: true,
		preferenceService: PreferenceService(),
		locationPermissionManager: LocationPermissionManager(),
		bluetoothPermissionManager: BluetoothPermissionManager(),
		notificationPermissionManager: NotificationPermissionManager(),
		beaconBroadcastService: BeaconBroadcastService(),
		beaconDiscoveryService: BeaconDiscoveryService(),
		backgroundMonitorService: BackgroundMonitorService.shared
	)
	.modelContainer(PreviewContainer.shared)
}
