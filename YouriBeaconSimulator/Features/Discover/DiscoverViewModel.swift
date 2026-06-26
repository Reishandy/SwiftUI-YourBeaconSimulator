//
//  DiscoverViewModel.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import Foundation
import SwiftData

@Observable
class DiscoverViewModel {
	private var modelContext: ModelContext
	private var preferenceService: PreferenceService
	private var permissionService: PermissionService
	
	private(set) var projects: [BroadcastProject] = []
	
	init(modelContext: ModelContext, preferenceService: PreferenceService, permissionService: PermissionService) {
		self.modelContext = modelContext
		self.preferenceService = preferenceService
		self.permissionService = permissionService
		
		self.fetchData()
	}
	
	func fetchData() {
		do {
			projects = try modelContext.fetch(FetchDescriptor<BroadcastProject>(
				sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
			))
		} catch {
			print("ERROR > Failed populating DiscoverViewModel: \(error)")
		}
	}
}
