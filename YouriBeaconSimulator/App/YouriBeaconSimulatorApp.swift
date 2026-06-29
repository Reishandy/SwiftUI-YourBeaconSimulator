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
	
	let container: ModelContainer
	let loggingService: LoggingService
	
	@State var preferenceService = PreferenceService()
	@State var locationPermissionManager = LocationPermissionManager()
	@State var bluetoothPermissionManager = BluetoothPermissionManager()
	@State var notificationPermissionManager = NotificationPermissionManager()
	
	@State var beaconBroadcastService = BeaconBroadcastService()
	@State var beaconDiscoveryService = BeaconDiscoveryService()
	
	var deviceDescription: String {
#if os(iOS)
		return "\(UIDevice.current.name) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))"
#elseif os(macOS)
		return Host.current().localizedName ?? "Mac"
#else
		return "Unknown Device"
#endif
	}
	
	init() {
		do {
			let schema = Schema([
				BroadcastProject.self,
				BroadcastBeacon.self,
				LogSession.self,
				LogEvent.self
			])
			
			container = try ModelContainer(for: schema)
			
			loggingService = LoggingService(modelContainer: container)
		} catch {
			fatalError("Failed to initialize SwiftData container: \(error)")
		}
	}
	
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
			.modelContainer(container)
#if os(macOS)
			.frame(minWidth: 700)
			.frame(maxWidth: 1000)
#endif
			.task {
				beaconBroadcastService.setLogger(loggingService)
				beaconDiscoveryService.setLogger(loggingService)
				BackgroundMonitorService.shared.setLogger(loggingService)
				
				await loggingService.startNewSession()
				await loggingService.log(message: "App Session Started on \(deviceDescription)", category: .system)
			}
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
