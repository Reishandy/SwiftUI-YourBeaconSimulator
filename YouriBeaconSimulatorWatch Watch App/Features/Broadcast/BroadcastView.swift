//
//  BroadcastView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import SwiftUI

struct BroadcastView: View {
	@Environment(WatchConnectivityService.self) private var connectivity
	
    var body: some View {
		List {
			ForEach(connectivity.phoneState?.broadcastableProjects ?? []) { project in
				Section(project.name) {
					ForEach(project.beacons) { beacon in
						Button {
							connectivity.send(.startBroadcast(beaconID: beacon.id))
						} label: {
							HStack {
								VStack(alignment: .leading) {
									Text("Major: \(String(beacon.majorID))")
										.font(.caption)
									
									Text("Minor: \(String(beacon.minorID))")
										.font(.caption2)
										.foregroundStyle(.secondary)
								}
								
								Spacer()
								
								Image(systemName: "play.fill")
							}
							.padding()
						}
					}
				}
			}
		}
		.listStyle(.carousel)
		.navigationTitle("Broadcast")
		.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
	NavigationStack {
		BroadcastView()
			.environment(WatchConnectivityService.previewMock(
				state: WatchPreviewData.idleForegroundState
			))
	}
}
