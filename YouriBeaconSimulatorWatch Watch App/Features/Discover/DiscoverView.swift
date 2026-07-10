//
//  DiscoverView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import SwiftUI

struct DiscoverView: View {
	@Environment(WatchConnectivityService.self) private var connectivity
	
    var body: some View {
		List {
			ForEach(connectivity.phoneState?.broadcastableProjects ?? []) { project in
				Button {
					connectivity.send(.startDiscovery(projectID: project.id))
				} label: {
					VStack(alignment: .leading) {
						Text(project.name)
							.font(.caption)
						
						Text("\(project.beacons.count) beacons")
							.font(.caption2)
							.foregroundStyle(.secondary)
					}
					.padding()
				}
			}
		}
		.listStyle(.carousel)
		.navigationTitle("Discover")
		.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
	NavigationStack {
		DiscoverView()
			.environment(WatchConnectivityService.previewMock(
				state: WatchPreviewData.idleForegroundState
			))
	}
}
