//
//  DiscoverView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData
import CoreLocation

struct DiscoverView: View {
	@State var discoverViewModel: DiscoverViewModel
	
	// TODO: Debug
	@State private var selectedItem: String?
	
	var body: some View {
		NavigationSplitView {
			Group {
				if discoverViewModel.locationAuthorization == .notDetermined {
					EmptyStateView(
						systemImage: "location.fill",
						title: "Location Access Required",
						subtitle: "iBeacon discovery requires location permissions to detect and measure distances to nearby beacons.",
						actionText: "Enable Location"
					) {
						discoverViewModel.requestLocationPermission()
					}
				} else if discoverViewModel.locationAuthorization == .denied ||
							discoverViewModel.locationAuthorization == .restricted {
					EmptyStateView(
						systemImage: "location.slash.fill",
						title: "Location Access Blocked",
						subtitle: "Please enable Location permission in Settings to discover iBeacons.",
						actionText: "Open Settings"
					) {
#if os(iOS)
						if let url = URL(string: UIApplication.openSettingsURLString) {
							UIApplication.shared.open(url)
						}
#endif
					}
				} else {
					ZStack {
						if discoverViewModel.isDiscovering {
							listView
						} else {
							DiscoverFormView(
								selectedProject: $discoverViewModel.selectedProject,
								proximityUUID: $discoverViewModel.proximityUUID,
								isBackgroundEnabled: $discoverViewModel.isBackgroundEnabled,
								isNotificationPermissionGranted: $discoverViewModel.isNotificationPermissionGranted,
								availableProjects: discoverViewModel.projects,
								onGrantPermissionClick: {
									// TODO: Actual notification permission request
									discoverViewModel.isNotificationPermissionGranted = true
								},
								onStartDiscoveryClick: {
									withAnimation {
										discoverViewModel.startDiscovery()
									}
								}
							)
						}
					}
				}
			}
			.navigationTitle("Discover")
			.navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 500)
			.toolbar {
				if discoverViewModel.isDiscovering {
					ToolbarItem(placement: .primaryAction) {
						Button("Stop") {
							withAnimation {
								discoverViewModel.stopDiscovery()
							}
						}
					}
				}
			}
		} detail: {
			if let selectedItem {
				Text("Selected: \(selectedItem)")
					.navigationTitle(selectedItem)
			} else {
				Text("Select an item from the sidebar")
					.foregroundColor(.secondary)
			}
		}
	}
	
	@ViewBuilder
	private var listView: some View {
		// TODO: Item list
		List(1...99, id: \.self, selection: $selectedItem) { item in
			NavigationLink("Item \(item)", value: "Item \(item)")
		}
	}
}

#Preview {
	let permissionService = PermissionService()
	
	DiscoverView(discoverViewModel: DiscoverViewModel(modelContext: PreviewContainer.shared.mainContext, preferenceService: PreferenceService(), permissionService: permissionService))
}
