//
//  YouriBeaconSimulatorApp.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData
import CoreBluetooth

import CloudKit

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
	@State var deviceIdentifierService = DeviceIdentifierService()
	
	@State var beaconBroadcastService = BeaconBroadcastService()
	@State var beaconDiscoveryService = BeaconDiscoveryService()
	
#if os(iOS)
	@State private var phoneStateAggregator: PhoneStateAggregator?
#endif
	
	var deviceDescription: String {
#if os(iOS)
		return "\(UIDevice.current.name) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))"
#elseif os(macOS)
		let version = ProcessInfo.processInfo.operatingSystemVersion
		return "\(Host.current().localizedName ?? "Mac") (macOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion))"
#else
		return "Unknown Device"
#endif
	}
	
	init() {
		print(CKRecord.self)
		
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
				
#if os(iOS)
				phoneStateAggregator = PhoneStateAggregator(
					broadcastService: beaconBroadcastService,
					discoveryService: beaconDiscoveryService,
					modelContext: container.mainContext
				)
				
				PhoneConnectivityService.shared.onCommand = { [beaconBroadcastService, beaconDiscoveryService] command in
					switch command {
					case .startBroadcast(let beaconID):
						guard
							let beacon = try? container.mainContext.fetch(
								FetchDescriptor<BroadcastBeacon>(predicate: #Predicate { $0.id == beaconID })
							).first,
							bluetoothPermissionManager.authorization == .allowedAlways,
							bluetoothPermissionManager.state == .poweredOn
						else {
							phoneStateAggregator?.setCommandFailed()
							return
						}
						beaconBroadcastService.startBroadcasting(beacon: beacon, txPower: -59)
						
					case .stopBroadcast:
						beaconBroadcastService.stopBroadcasting()
					case .startDiscovery(let projectID):
						guard
							let project = try? container.mainContext.fetch(
								FetchDescriptor<BroadcastProject>(predicate: #Predicate { $0.id == projectID })
							).first,
							let uuid = UUID(uuidString: project.proximityUUID)
						else {
							phoneStateAggregator?.setCommandFailed()
							return
						}
						beaconDiscoveryService.startDiscovery(uuid: uuid) { }
						
					case .stopDiscovery:
						beaconDiscoveryService.stopDiscovery()
					}
				}
#endif
				
				Task {
					await loggingService.startNewSession(
						deviceDescription: deviceDescription,
						deviceIdentifier: deviceIdentifierService.getDeviceUUID()
					)
				}
			}
		}
#if os(macOS)
		.windowResizability(.contentSize)
#endif
		.onChange(of: scenePhase) { oldPhase, newPhase in
			if newPhase == .background {
				beaconBroadcastService.stopBroadcasting()
			}
			
#if os(iOS)
			phoneStateAggregator?.setForeground(newPhase != .background)
#endif
		}
	}
}
