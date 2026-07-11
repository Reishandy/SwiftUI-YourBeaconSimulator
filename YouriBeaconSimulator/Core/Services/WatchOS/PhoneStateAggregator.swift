//
//  PhoneStateAggregator.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

#if os(iOS)
import Foundation
import Observation
import SwiftData

@MainActor
final class PhoneStateAggregator {
	private let broadcastService: BeaconBroadcastService
	private let discoveryService: BeaconDiscoveryService
	private let modelContext: ModelContext
	
	private var isForeground: Bool = false
	private var lastCommandError: String?
	
	private var cachedProjectSummaries: [BroadcastProjectSummary] = []
	
	init(
		broadcastService: BeaconBroadcastService,
		discoveryService: BeaconDiscoveryService,
		modelContext: ModelContext
	) {
		self.broadcastService = broadcastService
		self.discoveryService = discoveryService
		self.modelContext = modelContext
		refreshProjects()
		observe()
		observeModelChanges()
	}
	
	func setForeground(_ isForeground: Bool) {
		self.isForeground = isForeground
		push()
	}
	
	func setCommandFailed() {
		push(commandFailedAt: .now)
	}
	
	private func observe() {
		withObservationTracking {
			_ = broadcastService.activeBeacon
			_ = discoveryService.discoveredBeacons
			_ = discoveryService.activeUUID
		} onChange: {
			Task { @MainActor [weak self] in
				self?.push()
				self?.observe()
			}
		}
	}
	
	private func observeModelChanges() {
		NotificationCenter.default.addObserver(
			forName: ModelContext.didSave,
			object: modelContext,
			queue: .main
		) { [weak self] notification in
			let relevantKeys: [ModelContext.NotificationKey] = [.insertedIdentifiers, .updatedIdentifiers, .deletedIdentifiers]
			
			let touchedRelevantModel = relevantKeys.contains { key in
				guard let identifiers = notification.userInfo?[key.rawValue] as? [PersistentIdentifier] else { return false }
				return identifiers.contains { $0.entityName == "BroadcastProject" || $0.entityName == "BroadcastBeacon" }
			}
			
			if touchedRelevantModel {
				Task { @MainActor [weak self] in
					self?.refreshProjects()
				}
			}
		}
	}
	
	private func refreshProjects() {
		let projects = (try? modelContext.fetch(
			FetchDescriptor<BroadcastProject>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
		)) ?? []
		
		cachedProjectSummaries = projects.map { project in
			BroadcastProjectSummary(
				id: project.id,
				name: project.name,
				proximityUUID: project.proximityUUID,
				beacons: project.sortedBeacons.map {
					BroadcastBeaconSummary(id: $0.id, beaconName: $0.beaconName, majorID: $0.majorID, minorID: $0.minorID)
				}
			)
		}
		push()
	}
	
	private func push(commandFailedAt: Date? = nil) {
		let state = PhoneState(
			isForeground: isForeground,
			broadcastingBeaconID: broadcastService.activeBeacon?.id,
			broadcastableProjects: cachedProjectSummaries,
			discoveringProjectUUID: discoveryService.activeUUID?.uuidString,
			discoveredBeacons: discoveryService.discoveredBeacons.map {
				DiscoveredBeaconSummary(major: $0.major, minor: $0.minor, proximity: $0.proximity, isCurrentlyActive: $0.isCurrentlyActive)
			},
			commandFailedAt: commandFailedAt,
			updatedAt: .now
		)
		PhoneConnectivityService.shared.pushState(state)
		lastCommandError = nil
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
#endif
