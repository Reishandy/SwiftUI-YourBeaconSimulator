//
//  DiscoverViewModel.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import Foundation
import SwiftData
import CoreBluetooth
import CoreLocation
import UserNotifications
#if os(iOS)
import UIKit
#endif

@Observable
class DiscoverViewModel {
	private var modelContext: ModelContext
	private var preferenceService: PreferenceService
	
	private var locationPermissionManager: LocationPermissionManager
	private var bluetoothPermissionManager: BluetoothPermissionManager
	private var notificationPermissionManager: NotificationPermissionManager
	
	private var discoveryService: BeaconDiscoveryService
	private var backgroundMonitorService: BackgroundMonitorService
	private var previewBeacons: [DiscoveredBeacon]?
	
	private(set) var projects: [BroadcastProject] = []
	
	var discoveredBeacons: [DiscoveredBeacon] {
		previewBeacons ?? discoveryService.discoveredBeacons
	}
	var targetBeacons: [DiscoveredBeacon] {
		guard let target = UUID(uuidString: proximityUUID) else { return [] }
		return discoveredBeacons.filter { $0.uuid == target }
	}
	var otherBeacons: [DiscoveredBeacon] {
		guard let target = UUID(uuidString: proximityUUID) else { return [] }
		return discoveredBeacons.filter { $0.uuid != target }
	}
	
	var bluetoothAuthorization: CBManagerAuthorization { bluetoothPermissionManager.authorization }
	var bluetoothState: CBManagerState { bluetoothPermissionManager.state }
	var locationAuthorization: CLAuthorizationStatus { locationPermissionManager.authorizationStatus }
	var notificationAuthorization: UNAuthorizationStatus { notificationPermissionManager.authorizationStatus }
	
	var isDiscovering: Bool = false
	var selectedBeaconID: String? = nil
	var selectedBeacon: DiscoveredBeacon? { discoveredBeacons.first(where: { $0.id == selectedBeaconID }) }
	var selectedProject: BroadcastProject? = nil
	var proximityUUID: String = ""
	
	var isBackgroundEnabled: Bool {
		get { preferenceService.isBackgroundNotificationEnabled }
		set {
			preferenceService.isBackgroundNotificationEnabled = newValue
#if os(iOS)
			if let uuid = UUID(uuidString: proximityUUID) {
				backgroundMonitorService.updateMonitoring(for: uuid, isEnabled: newValue)
			}
#endif
		}
	}
	
	var isBackgroundReady: Bool {
		locationAuthorization == .authorizedAlways &&
		(notificationAuthorization == .authorized || notificationAuthorization == .provisional)
	}
	
#if os(iOS)
	var hasDeniedBackgroundPermissions: Bool {
		if locationAuthorization == .denied || locationAuthorization == .restricted || notificationAuthorization == .denied {
			return true
		}
		if preferenceService.hasRequestedAlwaysLocation && locationAuthorization == .authorizedWhenInUse {
			return true
		}
		return false
	}
#endif
	
	init(
		modelContext: ModelContext,
		preferenceService: PreferenceService,
		locationPermissionManager: LocationPermissionManager,
		bluetoothPermissionManager: BluetoothPermissionManager,
		notificationPermissionManager: NotificationPermissionManager,
		discoveryService: BeaconDiscoveryService,
		backgroundMonitorService: BackgroundMonitorService,
		previewBeacons: [DiscoveredBeacon]? = nil
	) {
		self.modelContext = modelContext
		self.preferenceService = preferenceService
		self.locationPermissionManager = locationPermissionManager
		self.bluetoothPermissionManager = bluetoothPermissionManager
		self.notificationPermissionManager = notificationPermissionManager
		self.discoveryService = discoveryService
		self.backgroundMonitorService = backgroundMonitorService
		self.previewBeacons = previewBeacons
		
		if let savedUUID = preferenceService.selectedUUID {
			self.proximityUUID = savedUUID.uuidString
		}
		
		self.fetchData()
	}
	
	func fetchData() {
		do {
			projects = try modelContext.fetch(FetchDescriptor<BroadcastProject>(
				sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
			))
			
			if !proximityUUID.isEmpty {
				selectedProject = projects.first(where: { $0.proximityUUID.caseInsensitiveCompare(proximityUUID) == .orderedSame })
			}
		} catch {
			print("ERROR > Failed populating DiscoverViewModel: \(error)")
		}
	}
	
	func requestLocationPermission() {
		Task { _ = await locationPermissionManager.requestWhenInUse() }
	}
	
	func requestBluetoothPermission() {
		Task { _ = await bluetoothPermissionManager.requestPermission() }
	}
	
#if os(iOS)
	func requestBackgroundPermissions() {
		Task {
			if locationAuthorization == .notDetermined {
				_ = await locationPermissionManager.requestWhenInUse()
			}
			
			if locationAuthorization == .authorizedWhenInUse {
				preferenceService.hasRequestedAlwaysLocation = true
				_ = await locationPermissionManager.requestAlways()
			}
			
			if notificationAuthorization == .notDetermined {
				_ = await notificationPermissionManager.requestPermission()
			}
		}
	}
#endif
	
	func startDiscovery() {
		guard let uuid = UUID(uuidString: proximityUUID) else { return }
		
		Task {
#if os(macOS)
			var auth = bluetoothPermissionManager.authorization
			if auth == .notDetermined { auth = await bluetoothPermissionManager.requestPermission() }
			guard auth == .allowedAlways, bluetoothPermissionManager.state == .poweredOn else { return }
#else
			var auth = locationPermissionManager.authorizationStatus
			if auth == .notDetermined { auth = await locationPermissionManager.requestWhenInUse() }
			guard auth == .authorizedWhenInUse || auth == .authorizedAlways else { return }
#endif
			
			preferenceService.selectedUUID = uuid
			isDiscovering = true
			
			if let previewBeacons {
				self.previewBeacons = previewBeacons.map { mockBeacon in
					DiscoveredBeacon(uuid: uuid, major: mockBeacon.major, minor: mockBeacon.minor, rssi: mockBeacon.rssi, accuracy: mockBeacon.accuracy, proximity: mockBeacon.proximity, lastSeen: mockBeacon.lastSeen)
				}
				return
			}
			
#if os(iOS)
			if isBackgroundEnabled {
				backgroundMonitorService.updateMonitoring(for: uuid, isEnabled: true)
			}
#endif
			
			discoveryService.startDiscovery(uuid: uuid) {
#if os(iOS)
				Task { @MainActor in
					let generator = UIImpactFeedbackGenerator(style: .light)
					generator.prepare()
					generator.impactOccurred()
				}
#endif
			}
		}
	}
	
	func stopDiscovery() {
		isDiscovering = false
		discoveryService.stopDiscovery()
	}
}
